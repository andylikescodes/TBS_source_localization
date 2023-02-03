filename = 'data/Andy/Session_1/TBS_pilot000003_s1.eeg';

%% STEP 1
% load data
hdr = ft_read_header(filename);


ev = ft_read_event(filename);
ev = ev(strcmp({ev.type},{'Stimulus'}));
ev_idx = strcmp({ev.value},{'S 25'}); %strcmp({ev.value},{'S 20'})+strcmp({ev.value},{'S 30'})+strcmp({ev.value},{'S 40'})+strcmp({ev.value},{'S 50'});%strcmp({ev.value},{'S 25'}); %
ev_spl = [ev(logical(ev_idx)).sample] + wt';
trl = [ev_spl-hdr.Fs*3; ev_spl+floor(hdr.Fs*.8); -ones(1,length(ev_spl))*hdr.Fs*3]';
trl(discard,:) = [];
ev_idx = [0 ev_idx(1:(length(ev_idx)-1))];

label = strcmp({ev(logical(ev_idx)).value},'S 20') + strcmp({ev(logical(ev_idx)).value},'S 30')*2 + strcmp({ev(logical(ev_idx)).value},'S 40')*3 + strcmp({ev(logical(ev_idx)).value},'S 50')*4;
label(discard) = [];

cfg = [];
%cfg.channel = 'eeg';
cfg.dataset = filename;
cfg.trl = trl;
cfg.dftfilter     = 'yes';
cfg.dftfreq       = [60 120 180];
% cfg.lpfilter      = 'yes';
% cfg.lpfreq        = 30;




data_step01 = ft_preprocessing(cfg);
data_step01.trialinfo = label';

%% STEP 2
% eog regression
 
data_step02 = data_step01;

chans = setdiff(data_step01.label,{'VEOG','HEOG','R Hand'});

% get EOG
hEOG = zeros(length(data_step01.trial),length(data_step01.trial{1}(1,:)));
vEOG = zeros(length(data_step01.trial),length(data_step01.trial{1}(1,:)));
for k = 1:length(data_step01.trial)
    hEOG(k,:) = data_step01.trial{k}(strcmp(data_step01.label,'HEOG'),:);
    vEOG(k,:) = data_step01.trial{k}(strcmp(data_step01.label,'VEOG'),:);
end


for j = 1:length(chans)
    chan_select = strcmp(data_step01.label, chans(j));
    temp_chan = zeros(length(data_step01.trial),length(data_step01.trial{1}(1,:)));
    for k = 1:length(data_step01.trial)
        temp_lm =  fitlm([hEOG(k,:); vEOG(k,:)]',data_step01.trial{k}(chan_select,:));
        data_step02.trial{k}(chan_select,:) = temp_lm.Residuals.Raw;
    end
end

%% STEP 3 Low pass
cfg = [];
cfg.lpfilter      = 'yes';
cfg.lpfreq        = 3;
%cfg.channel = 'Cz';
data_step02_1 = ft_preprocessing(cfg, data_step02);

cfg=[];
cfg.channel ='eeg';
data_step03 = ft_selectdata(cfg, data_step02_1);

%% STEP 4 Automatic rejection


to_keep2 = ones(1,length(data_step03.trial));

for j = 1:length(to_keep2)
    for k = 1:length(data_step03.label)

        % maxabs 150

        if max(abs(data_step03.trial{j}(k,:))) > 150
            to_keep2(j) = 0;
        end

    end
end

cfg.trials = logical(to_keep2);
data_step04= ft_selectdata(cfg, data_step03);
label(to_keep2==0)=[];



%% PLOT PRE-POST (1/2 vs 3/4)
pre = label==1 | label==2;
post = label==3 | label==4;
data_step04.sampleinfo = floor(data_step04.sampleinfo);

cfg = [];
cfg.channel = 'Cz';
cfg.trials = pre;
preTBS = ft_timelockanalysis(cfg, data_step04);
cfg.trials = post;
postTBS = ft_timelockanalysis(cfg, data_step04);

cfg=[];
cfg.showlegend    = 'yes';

ft_singleplotER([],preTBS, postTBS)


%% CONFIDENCE INTERVALS



%% SAVE DATA
save('data/Tomas/Session_1/results/data.mat','data_step01','data_step02','data_step02_1','data_step03','data_step04','label')
%plot(mean(hEOG,1))
%% RT ANALYSIS
csv_filename = 'data/Andy/Session_1/pilot03_s1_Libet_TBS_v5_2022_Dec_02_1545.csv';
m = readmatrix(csv_filename);
wt = m(:,39);
wt = wt(~isnan(m(:,39)));
discard = wt<2.56;
wt = floor(wt*hdr.Fs);
%wt = wt(~(wt<2.56));

%

%% TFR analysis
cfg=[];
cfg.latency = [-3 0];
data_step05 = ft_selectdata(cfg, data_step04);

pre = label==1 | label==2;
post = label==3 | label==4;
data_step04.sampleinfo = floor(data_step04.sampleinfo);

cfg = [];
cfg.method = 'mtmfft';
cfg.foi = 1:0.2:30;
cfg.tapsmofrq = .3;
cfg.channel = 'Cz';

cfg.trials = pre;
preTBS = ft_freqanalysis(cfg, data_step05);



cfg.trials = post;
postTBS = ft_freqanalysis(cfg, data_step05);

cfg=[];
cfg.showlegend    = 'yes';

ft_singleplotER([],preTBS, postTBS)
