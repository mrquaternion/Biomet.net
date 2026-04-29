function biometNetPath = findBiometNetPath
% biometNetPath = findBiometNetPath % find path to current Biomet.net
%
% This function returns path to Biomet.net by looking
% at the location of read_bor.m
%
%
% Zoran Nesic               File created:       Apr 28, 2026
%                           Last modification:  Apr 28, 2026
%

%
% Revisions:
%

funA = which('read_bor');     % First find the path to Biomet.net by looking for a standard Biomet.net functions
tstPattern = [filesep 'Biomet.net' filesep];
indFirstFilesep=strfind(lower(funA),lower(tstPattern));
biometNetPath = fullfile(funA(1:indFirstFilesep-1),tstPattern);
