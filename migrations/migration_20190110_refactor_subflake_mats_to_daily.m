% MIGRATION 20190110 - Refactor subflake mat files to be daily
%
%   This script is only to be run ONCE for a single cached path.
%
%   It will go through the current cached path specified by the
%   CACHED_PATH_SELECTION variable, converting all of the subflake and
%   goodsubflake mat files to daily files.  i.e. each mat file will now
%   encompass all original images and cropped images from a single day.
%
%   If there is no mat file for a day, then there were no images obtained
%   on that day.
%
%   Required vars:
%       CACHED_PATH_SELECTION - integer from 1 to n, specifies where the
%           mat files are to be updated

if ~exist('CACHED_PATH_SELECTION', 'var')
    error('You must specify the cache to migrate using the `CACHED_PATH_SELECTION` variable.')
end

pathToFlakes = get_cachedpath(CACHED_PATH_SELECTION);

matFilePath = [pathToFlakes 'cache' filesep];

numAllFlakeFiles = length(dir([matFilePath 'data*_allflakes.mat']));
numGoodFlakeFiles = length(dir([matFilePath 'data*_goodflakes.mat']));
if numAllFlakeFiles == 0
    disp('No data to migrate.')
    return;
elseif numGoodFlakeFiles == 0
    disp('No good flakes data to migrate.')
end
if numAllFlakeFiles > 0
end

% Go from data[int]_allflakes.mat to data_[date]_allflakes.mat (same for goodflakes)

%% All flakes
textprogressbar(['Migrating ' num2str(numAllFlakeFiles) ' all flake files...'], numAllFlakeFiles);

theDate = 0;        % the current date
dates = [];   % keep a list of all dates with files
firstInD = 1; % index into allFlakes of first flake in date d
lastInD = 1;  %#ok<NASGU> index into allFlakes of last flake in date d

for i = 0 : numAllFlakeFiles - 1
    load([matFilePath 'data' num2str(i) '_allflakes.mat'], 'subFlakes');
    allFlakes = subFlakes; clear subFlakes
    lastFlake = find(cellfun(@isempty, allFlakes(:,1)), 1, 'first');
    for j = 1 : lastFlake - 1
        flake = parse_masc_filename(allFlakes{j,1});
        d = datenum(datestr(flake.date,'yyyymmdd'),'yyyymmdd');
        if theDate ~= d
            % Need to make a new file for theDate
            if theDate ~= 0
                % save the data for theDate
                lastInD = j;
                dFile = [matFilePath 'data_' datestr(theDate,'yyyymmdd') '_allflakes.mat'];
                if ismember(theDate, dates)
                    % already a file for theDate, update it
                    load(dFile, 'subFlakes');
                    subFlakes = [subFlakes; allFlakes(firstInD:lastInD,:)]; %#ok<AGROW>
                    save(dFile, 'subFlakes', '-append')
                else
                    % new file for theDate
                    subFlakes = allFlakes(firstInD:lastInD,:);
                    save(dFile, 'subFlakes', 'settings')
                    dates = [dates theDate]; %#ok<AGROW> append theDate to dates
                end
            end
            theDate = d; % update theDate
            firstInD = j;
        end
    end
    textprogressbar(i);
end
if theDate ~= 0
    % save the data for the last date
    lastInD = j;
    dFile = [matFilePath 'data_' datestr(theDate,'yyyymmdd') '_allflakes.mat'];
    if ismember(theDate, dates)
        % already a file for last date, update it
        load(dFile, 'subFlakes');
        subFlakes = [subFlakes; allFlakes(firstInD:lastInD,:)];
        save(dFile, 'subFlakes', '-append')
    else
        % new file for last date
        subFlakes = allFlakes(firstInD:lastInD,:);
        save(dFile, 'subFlakes', 'settings')
        dates = [dates theDate]; %#ok<NASGU> append theDate to dates
    end
end
textprogressbar(' done!');

%% Good Flakes
textprogressbar(['Migrating ' num2str(numGoodFlakeFiles) ' good flake files...'], numGoodFlakeFiles);

theDate = 0;        % the current date
dates = [];   % keep a list of all dates with files
firstInD = 1; % index into allFlakes of first flake in date d
lastInD = 1;  % index into allFlakes of last flake in date d

for i = 0 : numGoodFlakeFiles - 1
    load([matFilePath 'data' num2str(i) '_goodflakes.mat'], 'goodSubFlakes');
    goodFlakes = goodSubFlakes; clear goodSubFlakes
    lastFlake = find(cellfun(@isempty, goodFlakes(:,1)), 1, 'first');
    for j = 1 : lastFlake - 1
        flake = parse_masc_filename(goodFlakes{j,1});
        d = datenum(datestr(flake.date,'yyyymmdd'),'yyyymmdd');
        if theDate ~= d
            % Need to make a new file for theDate
            if theDate ~= 0
                % save the data for theDate
                lastInD = j;
                dFile = [matFilePath 'data_' datestr(theDate,'yyyymmdd') '_goodflakes.mat'];
                if ismember(theDate, dates)
                    % already a file for theDate, update it
                    load(dFile, 'goodSubFlakes');
                    goodSubFlakes = [goodSubFlakes; goodFlakes(firstInD:lastInD,:)]; %#ok<AGROW>
                    save(dFile, 'goodSubFlakes', '-append')
                else
                    % new file for theDate
                    goodSubFlakes = goodFlakes(firstInD:lastInD,:);
                    save(dFile, 'goodSubFlakes', 'settings')
                    dates = [dates theDate]; %#ok<AGROW> append theDate to dates
                end
            end
            theDate = d; % update theDate
            firstInD = j;
        end
    end
    textprogressbar(i);
end
if theDate ~= 0
    % save the data for the last date
    lastInD = j;
    dFile = [matFilePath 'data_' datestr(theDate,'yyyymmdd') '_goodflakes.mat'];
    if ismember(theDate, dates)
        % already a file for last date, update it
        load(dFile, 'goodSubFlakes');
        goodSubFlakes = [goodSubFlakes; goodFlakes(firstInD:lastInD,:)];
        save(dFile, 'goodSubFlakes', '-append')
    else
        % new file for last date
        goodSubFlakes = goodFlakes(firstInD:lastInD,:);
        save(dFile, 'goodSubFlakes', 'settings')
        dates = [dates theDate]; % append theDate to dates
    end
end
textprogressbar(' done!');

% END MIGRATION
disp('Migration complete!')