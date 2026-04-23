function train_ML_gapfill(Years,siteID)
% funtion to call full run, including training of ML gapfilling pipeline
% if a model has already been trained, this can be skipped and gapfilling can be run using fr_automated_cleaning(Years,Sites,9)

numOfYears = length(Years);
numOfSites = length(Sites);

for cntSites = 1:numOfSites
    
    for cntYears = 1:numOfYears
        yy = Years(cntYears);
        yy_str = num2str(yy(1));

        %------------------------------------------------------------------
        % 9th stage is the methane-gapfill-ml python pipeline
        %------------------------------------------------------------------
        disp(['============== Running full ML gapfilling pipeline including training: ' siteID ' ' yy_str ' ==============']);
        runThirdStageCleaningMethaneGapfillML_test(yy,siteID,1);
        fprintf('============== End of cleaning stage 9 =============\n'); 
    end
end