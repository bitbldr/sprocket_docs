-module(print_time).
-export([format_utc_timestamp/2]).

format_utc_timestamp(Timestamp, Unit) ->
    {_, _, Micro} = Timestamp,
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_universal_time(Timestamp),

    Mstr = element(
        Month, {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    ),

    AMPM =
        case Hour < 12 of
            true -> "AM";
            false -> "PM"
        end,

    AMPMHour =
        case Hour > 12 of
            true -> Hour - 12;
            false -> Hour
        end,

    Formatted =
        case Unit of
            millisecond ->
                Milli = Micro div 1000,

                io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w.~3..0w ~s", [
                    Day, Mstr, Year, AMPMHour, Minute, Second, Milli, AMPM
                ]);
            _ ->
                io_lib:format("~2w ~s ~4w ~2w:~2..0w:~2..0w ~s", [
                    Day, Mstr, Year, AMPMHour, Minute, Second, AMPM
                ])
        end,

    erlang:iolist_to_binary(Formatted).
