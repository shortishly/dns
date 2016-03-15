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


-module(dns_header_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

all() ->
    [{group, tests}].

groups() ->
    [{tests, [parallel], common:all(?MODULE)}].


init_per_suite(Config) ->
    ok = application:load(dns),
    application:set_env(dns, udp_port, 3535),
    application:set_env(dns, http_port, 8181),
    {ok, _} = application:ensure_all_started(dns),
    Config.

end_per_suite(_Config) ->
    common:purge_application(dns).

class_in_test(_Config) ->
    1 = dns_class:lookup(in),
    in = dns_class:lookup(1).

class_cs_test(_Config) ->
    2 = dns_class:lookup(cs),
    cs = dns_class:lookup(2).

class_ch_test(_Config) ->
    3 = dns_class:lookup(ch),
    ch = dns_class:lookup(3).

class_hs_test(_Config) ->
    4 = dns_class:lookup(hs),
    hs = dns_class:lookup(4).

class_any_test(_Config) ->
    255 = dns_class:lookup(any),
    any = dns_class:lookup(255).

type_a_test(_Config) ->
    1 = dns_rr:lookup(a),
    a = dns_rr:lookup(1).

type_ns_test(_Config) ->
    2 = dns_rr:lookup(ns),
    ns = dns_rr:lookup(2).

type_cname_test(_Config) ->
    5 = dns_rr:lookup(cname),
    cname = dns_rr:lookup(5).

type_soa_test(_Config) ->
    6 = dns_rr:lookup(soa),
    soa = dns_rr:lookup(6).

type_ptr_test(_Config) ->
    12 = dns_rr:lookup(ptr),
    ptr = dns_rr:lookup(12).

type_mx_test(_Config) ->
    15 = dns_rr:lookup(mx),
    mx = dns_rr:lookup(15).

type_txt_test(_Config) ->
    16 = dns_rr:lookup(txt),
    txt = dns_rr:lookup(16).

type_aaaa_test(_Config) ->
    28 = dns_rr:lookup(aaaa),
    aaaa = dns_rr:lookup(28).

type_srv_test(_Config) ->
    33 = dns_rr:lookup(srv),
    srv = dns_rr:lookup(33).

type_opt_test(_Config) ->
    41 = dns_rr:lookup(opt),
    opt = dns_rr:lookup(41).

type_tsig_test(_Config) ->
    250 = dns_rr:lookup(tsig),
    tsig = dns_rr:lookup(250).

type_any_test(_Config) ->
    255 = dns_rr:lookup(any),
    any = dns_rr:lookup(255).

opcode_query_test(_Config)->
    query = dns_protocol:lookup(0),
    0 = dns_protocol:lookup(query).

opcode_update_test(_Config)->
    update = dns_protocol:lookup(5),
    5 = dns_protocol:lookup(update).

ocode_query_qr_test(_Config) ->
    query = dns_query:header(qr, 0),
    0 = dns_query:header(qr, query),
    response = dns_query:header(qr, 1),
    1 = dns_query:header(qr, response).

ocode_update_qr_test(_Config) ->
    query = dns_query:header(qr, 0),
    0 = dns_query:header(qr, query),
    response = dns_query:header(qr, 1),
    1 = dns_query:header(qr, response).

ocode_query_aa_test(_Config) ->
    false = dns_query:header(aa, 0),
    0 = dns_query:header(aa, false),
    true = dns_query:header(aa, 1),
    1 = dns_query:header(aa, true).

ocode_query_tc_test(_Config) ->
    false = dns_query:header(tc, 0),
    0 = dns_query:header(tc, false),
    true = dns_query:header(tc, 1),
    1 = dns_query:header(tc, true).

ocode_query_rd_test(_Config) ->
    false = dns_query:header(rd, 0),
    0 = dns_query:header(rd, false),
    true = dns_query:header(rd, 1),
    1 = dns_query:header(rd, true).

ocode_query_ra_test(_Config) ->
    false = dns_query:header(ra, 0),
    0 = dns_query:header(ra, false),
    true = dns_query:header(ra, 1),
    1 = dns_query:header(ra, true).

rcode_test(_Config) ->
    no_error = dns_rcode:lookup(0),
    0 = dns_rcode:lookup(no_error),
    format_error = dns_rcode:lookup(1),
    1 = dns_rcode:lookup(format_error),
    server_failure = dns_rcode:lookup(2),
    2 = dns_rcode:lookup(server_failure),
    name_error = dns_rcode:lookup(3),
    3 = dns_rcode:lookup(name_error),
    not_implemented = dns_rcode:lookup(4),
    4 = dns_rcode:lookup(not_implemented),
    refused = dns_rcode:lookup(5),
    5 = dns_rcode:lookup(refused),
    yx_domain = dns_rcode:lookup(6),
    6 = dns_rcode:lookup(yx_domain),
    yx_rrset = dns_rcode:lookup(7),
    7 = dns_rcode:lookup(yx_rrset),
    nx_rrset = dns_rcode:lookup(8),
    8 = dns_rcode:lookup(nx_rrset),
    not_auth = dns_rcode:lookup(9),
    9 = dns_rcode:lookup(not_auth),
    not_zone = dns_rcode:lookup(10),
    10 = dns_rcode:lookup(not_zone).
