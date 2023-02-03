%% Step 1: Load data
pilot = 'Tomas';
pilot_number = 1;
session = 2;
dirpath = ['data/' pilot '/' 'Session_' num2str(session) '/'];
csv_file = fullfile(dir([dirpath '*.csv']).folder,dir([dirpath '*.csv']).name);
eeg_file = fullfile(dir([dirpath '*.csv']).folder,dir([dirpath '*.eeg']).name);

ev = ft_read_event(eeg_file);
hdr = ft_read_header(eeg_file);
%dat = ft_read_data(eeg_file);

% extract trials
m = readmatrix(csv_file);
wt = m(:,39);
wt = wt(~isnan(m(:,39)));
discard = wt<2.56;
wt = floor(wt*hdr.Fs);

ev = ev(strcmp({ev.type},{'Stimulus'}));
ev_idx = strcmp({ev.value},{'S 25'});
ev_spl = [ev(logical(ev_idx)).sample] + wt';
trl = [ev_spl-hdr.Fs*3; ev_spl+floor(hdr.Fs*.8); -ones(1,length(ev_spl))*hdr.Fs*3]';
trl(discard,:) = [];
ev_idx = [0 ev_idx(1:(length(ev_idx)-1))];

label = strcmp({ev(logical(ev_idx)).value},'S 20') + strcmp({ev(logical(ev_idx)).value},'S 30')*2 + strcmp({ev(logical(ev_idx)).value},'S 40')*3 + strcmp({ev(logical(ev_idx)).value},'S 50')*4;
label(discard) = [];

% load eeg data
cfg = [];
cfg.dataset = eeg_file;
cfg.trl = trl;
cfg.dftfilter     = 'yes';
cfg.dftfreq       = [60 120 180];
cfg.channel = 1:63;
data_step01 = ft_preprocessing(cfg);
data_step01.trialinfo = label';

cfg.channel = {'R Hand'};
data_step01_emg = ft_preprocessing(cfg);

cfg.channel = {'VEOG', 'HEOG'};
data_step01_eog = ft_preprocessing(cfg);

%% Step 2: Down sample
cfg = [];
cfg.resamplefs = 500;

data_step02 = ft_resampledata(cfg, data_step01);
data_step02_emg = ft_resampledata(cfg, data_step01_emg);
data_step02_eog = ft_resampledata(cfg, data_step01_eog);

%% Step 3: EOG removal

% eog regression
 
data_step03 = data_step02;

% get EOG
hEOG = zeros(length(data_step02_eog.trial),length(data_step02_eog.trial{1}(1,:)));
vEOG = zeros(length(data_step02_eog.trial),length(data_step02_eog.trial{1}(1,:)));
for k = 1:length(data_step01.trial)
    vEOG(k,:) = data_step02_eog.trial{k}(1,:);
    hEOG(k,:) = data_step02_eog.trial{k}(2,:);
end


for j = 1:length(data_step02.label)
    for k = 1:length(data_step02.trial)
        temp_lm =  fitlm([hEOG(k,:); vEOG(k,:)]',data_step02.trial{k}(j,:)); %; vEOG(k,:)
        data_step03.trial{k}(j,:) = temp_lm.Residuals.Raw;
    end
end

%% Step 4: EMG removal

cfg = [];
cfg.method = 'trial';
[data_step04, chansel, trlsel] = ft_rejectvisual(cfg, data_step03);
label = label(trlsel);

%% Step 5: save data
load('data/results/data.mat')

cz_sel = strcmp(data_step04.label, 'Cz');

data(pilot_number, session).cz = zeros(length(data_step04.trial),length(data_step04.trial{1}(1,:)));
data(pilot_number, session).label = label;

for k = 1:length(data_step04.trial) 
    data(pilot_number, session).cz(k,:) = data_step04.trial{k}(cz_sel,:);
end

tmp_wt = wt(~discard);
data(pilot_number, session).wait_time = tmp_wt(trlsel);


%
cz_chan = strcmp(hdr.label,'Cz');
ev_spl = [ev(logical(ev_idx)).sample];
trl = [ev_spl-hdr.Fs/4; ev_spl; -ones(1,length(ev_spl))*hdr.Fs/4]';
trl(discard,:) = [];
ev_idx = [0 ev_idx(1:(length(ev_idx)-1))];

cfg = [];
cfg.dataset = eeg_file;
cfg.trl = trl;
cfg.dftfilter     = 'yes';
cfg.dftfreq       = [60 120 180];
cfg.channel = 'Cz';
data_baseline = ft_preprocessing(cfg);

%
save('data/results/data.mat','data')