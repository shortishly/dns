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

-module(dns_config).
-export([acceptors/1]).
-export([enabled/1]).
-export([nameservers/0]).
-export([port/1]).
-export([tsig_rr_fudge/0]).

acceptors(http) ->
    100.


enabled(http) ->
    get_env(http_enabled, true).


port(udp) ->
    get_env(udp_port, 53);
port(http) ->
    get_env(http_port, 80).


get_env(Name, Default) ->
    dns:get_env(Name, [app_env, {default, Default}]).


tsig_rr_fudge() ->
    300.

nameservers() ->
    lists:map(
      fun
          (Address) ->
              {ok, IP} = inet:parse_ipv4_address(Address),
              {IP, 53}
      end,
      string:tokens(
        dns:get_env(dns_nameservers, [os_env, {default, ""}]), ":")).
