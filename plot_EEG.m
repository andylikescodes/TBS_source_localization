load('data/results/data.mat')
time = -3:(1/500):0.8;

for i = 1:size(data,1)
    for j = 1:size(data,2)
        if (i)*2-1 + (j-1) == 6
            continue
        end
        subplot(size(data,1),size(data,2), (i)*2-1 + (j-1))
        idx_pre = data(i,j).label == 1 | data(i,j).label == 2;
        idx_post = data(i,j).label == 3 | data(i,j).label == 4; 
        idx_pre_w =data(i,j).label == 1;
        idx_pre_m =data(i,j).label == 2;
        idx_post_w =data(i,j).label == 3;
        idx_post_m =data(i,j).label == 4;        
        plot(time, lowpass(mean(data(i,j).cz(idx_pre,:),1),10,500)), hold on % - mean(data(i,j).cz(idx_pre,1:50),[1 2])
        plot(time, lowpass(mean(data(i,j).cz(idx_post,:),1),10,500)) %  - mean(data(i,j).cz(idx_post,1:50),[1 2])
        
        p_value = ranksum(data(i,j).wait_time(data(i,j).label==1 | data(i,j).label==2), data(i,j).wait_time(data(i,j).label==3 | data(i,j).label==4));
        subtitle(num2str(p_value));
        %plot(time(1:end), movmean(mean(data(i,j).cz(idx_pre,:),1)', [250 0])), hold on
        %plot(time(1:end), movmean(mean(data(i,j).cz(idx_post,:),1)', [250 0]))
        xlim([-3 0.8])
        
        
        % confidence intervals
        
        
    end
end

%% GA M1
GA_pre = mean(data(1,1).cz(data(1,1).label == 1 | data(1,1).label == 2,:),1)/3 + mean(data(3,1).cz(data(3,1).label == 1 | data(3,1).label == 2,:),1)/3 + mean(data(2,1).cz(data(2,1).label == 1 | data(2,1).label == 2,:),1)/3;
GA_post = mean(data(1,1).cz(data(1,1).label == 3 | data(1,1).label == 4,:),1)/3 + mean(data(3,1).cz(data(3,1).label == 3 | data(3,1).label == 4,:),1)/3 + mean(data(2,1).cz(data(2,1).label == 3 | data(2,1).label == 4,:),1)/3;
plot(time, GA_pre), hold on
plot(time, GA_post)

plot(time, lowpass(GA_pre,.1,500)), hold on
plot(time, lowpass(GA_post,.1,500))
% add baseline to EEG
% compute slope
% compue wt