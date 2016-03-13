%% Copyright (c) 2012-2016 Peter Morgan <peter.james.morgan@gmail.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.


-module(dns_update).

-export([decode/1]).
-export([encode/1]).
-export([header/2]).
-export([process/1]).


process(#{header := Header, updates := Updates} = Packet) ->
    lists:foreach(
      fun
          (#{labels := Name,
             class := Class, type := Type, ttl := 0}) ->
              dns_node:remove(Name, Class, Type);

          (#{labels := Name,
             class := in,
             type := Type, ttl := TTL, data := Data}) ->
              dns_node:add(Name, in, Type, TTL, Data)
      end, Updates),
    Packet#{header => Header#{qr => response, rcode => no_error}};

process(Packet) ->
    encode(process(decode(Packet))).


encode(#{header := #{id := ID, qr := QR, opcode := OPCODE, z := Z,
                     rcode := RCODE},
         zones := Zones,
         updates := Updates,
         prerequisites := Prerequisites,
         additional := Additionals}) ->

    Header = <<
               ID:16,
               (header(qr, QR)):1,
               (dns_protocol:lookup(OPCODE)):4,
               Z:7,
               (dns_rcode:lookup(RCODE)):4,
               (length(Zones)):16,
               (length(Updates)):16,
               (length(Prerequisites)):16,
               (length(Additionals)):16
             >>,

    {HeaderAndZones, Offsets} = dns_question:encode(Zones, Header),
    {Packet, _} = dns_rr:encode(HeaderAndZones,
                                Offsets,
                                Updates ++ Prerequisites ++ Additionals),
    Packet.

decode(<<
         ID:16,
         QR:1, OPCODE:4, Z:7, RCODE:4,
         ZOCOUNT:16,
         PRCOUNT:16,
         UPCOUNT:16,
         ADCOUNT:16,
         Remainder/binary
       >> = Packet) ->

    Header = #{id => ID,
               qr => header(qr, QR),
               opcode => dns_protocol:lookup(OPCODE),
               z => Z,
               rcode => dns_rcode:lookup(RCODE),
               zo_count => ZOCOUNT,
               pr_count => PRCOUNT,
               up_count => UPCOUNT,
               ad_count => ADCOUNT
              },

    {Zones, PrerequisiteRemainder} = dns_rr:zones(ZOCOUNT,
                                                  Remainder, Packet),

    {Prerequisites,
     UpdateRemainder} = dns_rr:resources(PRCOUNT,
                                         PrerequisiteRemainder,
                                         Packet),

    {Updates, AdditionalRemainder} = dns_rr:resources(UPCOUNT,
                                                      UpdateRemainder,
                                                      Packet),

    {Additional, <<>>} = dns_rr:resources(ADCOUNT,
                                          AdditionalRemainder,
                                          Packet),

    #{header => Header,
      zones => Zones,
      prerequisites => Prerequisites,
      updates => Updates,
      additional => Additional
     }.

header(Field, Value) ->
    dns_header:lookup(?MODULE, Field, Value).
