function ModelModels(refpoint)
if isempty(refpoint)
    refpoint=[14.5 0 0]; %Default reference point right in front of the magnetosphere
end


%Define what run you want to use
runname='Victoir_Veibell_041316_1';
%Default headers for model data
dataheaders={'x','y','z','bx','by','bz','jx','jy','jz','ux','uy','uz','p','rho'};

filename=sprintf('data/%s/DifferencesData_%s_%2.2f_%2.2f_%2.2f.mat',runname,runname,refpoint(1), refpoint(2), refpoint(3));

%Save data as a mat file for quicker future reading
if(exist(filename,'file'))
    load(filename)
else
    %Find number of existing time steps, then read in the model data for each
    %step into one array
    [status,ncuts]=system(sprintf('ls -1 data/%s/data/cuts/ | wc -l',runname));
    ncuts=str2double(ncuts);
    
    %Use grep to find each row with the reference point as coordinates,
    %then scan the result into an array
    [status, filedata]=system(sprintf('grep -h -e "^%3.6f %3.6f %3.6f" data/%s/data/cuts/*',refpoint(1), refpoint(2), refpoint(3), runname)); 
    data=cell2mat(textscan(filedata,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));

    %Variable names for model input data (solar wind)
    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};

    inputs=dlmread(sprintf('data/%s/%s_IMF.txt',runname,runname));

    %Bin the input data to be on the same grid as the model data that came
    %from brian's code
    for i=1:(ncuts-1)
        bininputs(i,:)=median(inputs((i-1)*30+1:i*30,:));
    end
    bininputs(ncuts,:)=median(inputs((ncuts-1)*30+1:end,:));
    
    save(filename,'data','inputs','bininputs','inputvars');
end

%Test correlation for models based on each of the different model input
%variables
for ctest=8:15
   [~,~,~,~,corr]=IR(data(:,9),bininputs(:,ctest),0,3);
   fprintf('%s: %2.3f\n',inputvars{ctest},corr);
end

%Test correlation for IR model using all MHD model input variables
[~,~,~,~,corr]=IR(data(:,9),bininputs(:,8:15),0,3);
fprintf('All: %2.3f\n',corr);

plot(data(:,9)); %check for Bz flip

%grep -h -e "-200.000000 0.000000 -47.000000" ../Differences/output/Brian_Curtis_042213_2/data/cuts/*


%Quick test plot of the surface to make sure we can see structure and that
%I'm reading things in correctly
    test=dlmread(sprintf('../Differences/output/%s/data/cuts/Step_70_Y_eq_0.txt',runname));
    x=unique(test(:,1));
    z=unique(test(:,3));
    d=reshape(test(:,8),length(x),[]);
    surf(x,z,d') %Make sure we're looking at the magnetosphere?
    
    
    %look at columns 8, 10, 11, 12?
