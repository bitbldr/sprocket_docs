-module(print_time).
-export([format_utc_timestamp/2]).

format_utc_timestamp(Timestamp, Unit) ->
    {_, _, Micro} = Timestamp,
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(Timestamp),

    Mstr = element(
        Month, {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    ),

    AM_PM =
        if
            Hour < 12 -> "AM";
            true -> "PM"
        end,

    Hour =
        if
            Hour > 12 -> Hour - 12;
            true -> Hour
        end,

    Formatted =
        case Unit of
            millisecond ->
                Milli = Micro div 1000,

                io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w.~3..0w ~s", [
                    Day, Mstr, Year, Hour, Minute, Second, Milli, AM_PM
                ]);
            _ ->
                io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w ~s", [
                    Day, Mstr, Year, Hour, Minute, Second, AM_PM
                ])
        end,

    erlang:iolist_to_binary(Formatted).
