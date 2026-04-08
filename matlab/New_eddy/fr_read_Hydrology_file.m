function [EngUnits, Header,tv,outStruct] = fr_read_Hydrology_file(fileName,assign_in,varName,flag30min)
%  fr_read_Hydrology_file - reads Carbonique Hydrology csv files
% 
% Inputs:
%   fileName            - data file
%   assign_in           - 'caller', 'base' - assignes the data to the
%                         actual column header names (logger variables)
%                         ither in callers space or in the base space.
%                         If empty or 0 no
%                         assignments are made
%   varName             - Used with 'caller'. Sets the name of the structure
%                         for the output variables. 
%   flag30min           - true:  convert to 30-min traces (default) 
%                         false: keep the original times
%
%
% (c) Zoran Nesic                   File created:       Jun 20, 2025
%                                   Last modification:  Apr  7, 2026
%

% Revisions (last one first):
%
% Apr 7, 2026 (Zoran)
%   - converted from using fr_read_generic_data_file to timetable-s.

arg_default('assign_in',[]);
arg_default('varName','outStruct');
arg_default('flag30min',true);

outStruct = struct([]);
EngUnits = [];    
Header = [];
tv = [];

try
    if ~exist(fileName,"file")
        error(['File: ' fileName ' does not exist!']);
    end
    fid = fopen(fileName,'r');
    if fid>0
        % The file header does not have a constant number of lines.
        % Read lines until you find the begining of the variable names: "TIME"
        oneLine = '';
        lineCount = 0;
        while ~startsWith(oneLine,'TIME') | lineCount >= 20
            lineCount = lineCount + 1;
            oneLine = fgetl(fid);
            Header{lineCount} = oneLine; %#ok<AGROW>
        end
        fclose(fid);
        if lineCount <15   
            % Header size is reasonable - try to load up the table
            tbIn = readtable(fileName,'NumHeaderLines',lineCount-1);
            % Remove all columns that are of a type: cell
            types = varfun(@class, tbIn, 'OutputFormat', 'cell');
            indCells = cellfun(@(x) ischar(x) && strcmp(x,'cell'), types);
            tbIn = removevars(tbIn,indCells);
            % depending on how the csv file was created the TIME might be
            % duration or datetime. Handle accordingly.
            if isduration(tbIn.TIME_HH_MM_SS_)
                TimeVector = tbIn.DATE_MM_DD_YYYY_ + tbIn.TIME_HH_MM_SS_;
            else
                TimeVector = tbIn.DATE_MM_DD_YYYY_ + (tbIn.TIME_HH_MM_SS_-datetime('today'));
            end
            tv = datenum(TimeVector);
            tbIn = addvars(tbIn, TimeVector, 'Before', 'FAULTCODE');
            tbIn = removevars(tbIn,{'TIME_HH_MM_SS_','DATE_MM_DD_YYYY_'});
            % convert to time table and sort by TimeVector
            tbIn = table2timetable(tbIn);
            tbIn = sortrows(tbIn);  
            if flag30min
                %resample at 30-min rate
                tbIn = retime(tbIn, 'regular', @nanmean, 'TimeStep', minutes(30));
            end
            tbTmp = timetable2table(tbIn);
            outStruct = table2struct(tbTmp,"ToScalar",true);
            outStruct.TimeVector = datenum(outStruct.TimeVector);
            if strcmpi(assign_in,'CALLER')
                assignin('caller',varName,outStruct);
            end
        end         
    end        
catch ME %#ok<CTCH>
    fprintf(2,'\nError reading file: %s. \n',fileName);
    fprintf(2,'%s\n',ME.message);
    fprintf(2,'Error on line: %d in %s\n\n',ME.stack(1).line,ME.stack(1).file);
end       


