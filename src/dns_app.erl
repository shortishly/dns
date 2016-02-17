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

-module(dns_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    try
        {ok, Sup} = dns_sup:start_link(),
        {ok, Sup, #{listeners => perhaps_start(http, [])}}
    catch
        _:Reason ->
            {error, Reason}
    end.

stop(#{listeners := Listeners}) ->
    lists:foreach(fun cowboy:stop_listener/1, Listeners);
stop(_State) ->
    ok.


perhaps_start(Prefix, A) ->
    case dns_config:enabled(Prefix) of
        false ->
            A;

        true ->
            {ok, _} = cowboy:start_http(
                        Prefix,
                        dns_config:acceptors(Prefix),
                        [{port, dns_config:port(Prefix)}],
                        [{env, [dispatch(Prefix)]}]),
            [Prefix | A]
    end.


dispatch(Prefix) ->
    {dispatch, cowboy_router:compile(resources(Prefix))}.


resources(http) ->
    [{<<"localhost">>,
      [{<<"/zones">>, dns_zone_resource, []},
       {<<"/secrets">>, dns_secret_resource, []}]}].
