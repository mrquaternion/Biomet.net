function fidLog = runThirdStageCleaningMethaneGapfillML(yearIn,siteID);
% runThirdStageCleaningMethaneGapfillML(yearIn,siteID)
%
% This function invokes Micromet third-stage cleaning Python pipeline.
% Usually, it's called by fr_automated_cleaning()
%
% Arguments
%   yearIn          - year to clean
%   siteID          - site ID as a char
%   TrainFill       - 1 runs all stages including training
%                   - 0 uses an existing model and just gapfill
    
    % use existing model by default
    % else call train_ML_gapfill(:_,:_) in your main_<siteID>.m
    arg_default('TrainFill', 0); 
    
    pythonPath = findBiometPythonPath;
    scriptPath = fullfile(pythonPath, 'methaneGapfillML.py');
    databasePath = findDatabasePath;
    if TrainFill == 1
        command = sprintf('/opt/anaconda3/envs/biomet/bin/python "%s" --site %s --year %s --db_path %s --mode %s', ...
                          scriptPath, siteID, num2str(yearIn), databasePath, 'full');
    elseif TrainFill == 0
        command = sprintf('/opt/anaconda3/envs/biomet/bin/python "%s" --site %s --year %s --db_path %s --mode %s', ...
                          scriptPath, siteID, num2str(yearIn), databasePath, 'gapfill');
    end
    status = system(command, '-echo');
   
end
        
function biometPythonPath = findBiometPythonPath
    funA = which('read_bor');
    tstPattern = [filesep 'Biomet.net' filesep];
    indFirstFilesep=strfind(funA,tstPattern);
    biometPythonPath = fullfile(funA(1:indFirstFilesep-1), tstPattern, 'Python');
end

function databasePath = findDatabasePath
    databasePath = biomet_path('yyyy');
    indY = strfind(databasePath,'yyyy');
    databasePath = databasePath(1:indY-2); 
end