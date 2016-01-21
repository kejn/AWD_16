function [ timeString ] = toTimeString( seconds )
%TOTIMESTRING Summary of this function goes here
%   Detailed explanation goes here
    minutes = seconds / 60;
    seconds = uint8(60*(minutes-floor(minutes)));
    minutes = uint16(minutes);
    timeString = sprintf('%d min %d sek',minutes,seconds);
end
