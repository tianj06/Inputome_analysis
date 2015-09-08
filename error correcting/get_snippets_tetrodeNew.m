function get_snippets_tetrodeNew(TT_id,wire_id,crosstype,ref,extName)
% example get_snippets_tetrode(3,3,'v',2,'.dat')

if nargin <4
    ref = 0;   % no self reference is used by default
    if nargin<3
        crosstype = 'a';  % find cross threshold for both peak and valley 
    end
end

%written to work for single wire
noise_window_step=50.0;
thresh_std=3;%3.7 number of stdevs above noise for threshold, p=0.0001
refractory_period=0.001;%1ms
snippet_points=32;
pre_points=round(snippet_points*0.5);
post_points=snippet_points-pre_points-1;

%read data file
wireNum = (TT_id-1)*4+wire_id;
filename = ['CSC' num2str(wireNum)  extName];
[channel_data, intTS, sample_rate] = readCSCfile(filename);
wireNum = str2num(filename(4:end-4));
extName = filename(end-3:end);
% if reference is used, subtracted reference
if ref 
    refFile = ['CSC' num2str(ref+4*floor((wireNum-1)/4)) extName];
    [ref_data, intTS, sample_rate] = readCSCfile(refFile);
    channel_data = channel_data - ref_data;
end
noise_window_step = round(noise_window_step*sample_rate);
search_radius=round(refractory_period*sample_rate/2);
refractory_period=round(refractory_period*sample_rate);

%calculate the noise on the channel and find cross threshold events
num_steps=floor(length(channel_data)/round(noise_window_step));
noise_std=zeros(1,num_steps);
crossings = [];
for j=1:num_steps
    this_window_t = noise_window_step*(j-1)+1:noise_window_step*j;
    this_window=channel_data(this_window_t);
    noise_std(j)=median(abs(this_window))/0.6745;%0.6745 is the location (in SDs) of the median of a normal distribution
    if strcmp(crosstype(1),'p')
        ind = crossing(this_window-thresh_std*noise_std(j)); 
        crossings = [crossings this_window_t(1) + ind];
    elseif strcmp(crosstype(1),'v')
        ind = crossing(this_window+thresh_std*noise_std(j)); 
        crossings = [crossings this_window_t(1) + ind];
    else
        ind = crossing(abs(this_window)-thresh_std*noise_std(j)); 
        crossings = [crossings this_window_t(1) + ind];        
    end
    if(rem(j,round(num_steps/100))==0)
        fprintf(['Noise Calculation %d Percent Complete.\n'],round(100*j/num_steps));
    end
end


early_crossings=find(diff(crossings)<refractory_period)+1;
crossings(early_crossings) = [];
if crossings(1) - search_radius<0
    crossings(1) = [];
end
if crossings(end) + search_radius>length(channel_data)
    crossings(end) = [];
end
num_crossings=length(crossings);

%find the maximum near each crossing point
loc_max=zeros(num_crossings,2);
for j=1:num_crossings
    if strcmp(crosstype(1),'p')
        [y,idx]=max(channel_data((crossings(j)-search_radius):(crossings(j)+search_radius)));
    elseif strcmp(crosstype(1),'v')
        [y,idx]=min(channel_data((crossings(j)-search_radius):(crossings(j)+search_radius)));
    else
        [y,idx]=max(abs(channel_data((crossings(j)-search_radius):(crossings(j)+search_radius))));
    end
    noise_bin=ceil(crossings(j)/round(noise_window_step));
    loc_max(j,1)=y/noise_std(noise_bin);
    loc_max(j,2)=crossings(j)-search_radius+idx-1;
    if(rem(j,round(num_crossings/100))==0)
        fprintf(['Find Unique %d Percent Complete.\n'],round(100*j/num_crossings));
    end
end
[unique_max idx1 idx2]=unique(loc_max(:,2));
loc_max=loc_max(idx1,:);

%for single wire, use loc_max as snippet_centers
snippet_centers=loc_max(:,2);
snippet_timestamp = intTS(snippet_centers)*10;
clear intTS

% read continous file from other csc files
channel_data = zeros(4,length(channel_data));
for i = 1:4
     tempfile = ['CSC' num2str(i+4*floor((wireNum-1)/4)) extName];
     dirInfo = dir(tempfile);
     if dirInfo.bytes > 10000000
        [channel_data(i,:), ~, ~] = readCSCfile(tempfile);
     end
end
% if want to use one of the wire as reference
if ref
    refData = channel_data(ref,:);
    for i = 1:4
        channel_data(i,:) = channel_data(i,:) - refData;
    end
end
%gather snippets from channel recordings
snippets=zeros(length(snippet_centers),4,snippet_points);
ind = [];
for k=1:length(snippet_centers)
    snippet_start=(snippet_centers(k)-pre_points);
    snippet_end=(snippet_centers(k)+post_points);
    if(snippet_start>0 && snippet_end<length(channel_data))
        snippets(k,:,:)=channel_data(:,snippet_start:snippet_end);
        ind = [ind k];
    end
    if(rem(k,round(length(snippet_centers)/100))==0)
        fprintf(['Find Unique %d Percent Complete.\n'],round(100*k/length(snippet_centers)));
    end
end
snippet_timestamp = snippet_timestamp(ind);

%write snippets to file in proper format
fid_a=fopen(['TT',num2str(TT_id),'.dat'],'w');
for j=1:size(snippets,1)
    this_snippet=zeros(1,129);
    this_snippet(1)=snippet_timestamp(j);
    this_snippet(2:129)=reshape(snippets(j,:,:),1,[]);
    fwrite(fid_a,this_snippet,'single','s');
end

fclose(fid_a);