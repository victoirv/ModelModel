function ModelModels


runname='Victoir_Veibell_041316_1'; 
dataheaders={'x','y','z','bx','by','bz','jx','jy','jz','ux','uy','uz','p','rho'};

refpoint=[14.5 0 0];
filename=sprintf('data/DifferencesData_%s_%2.2f_%2.2f_%2.2f.mat',runname,refpoint(1), refpoint(2), refpoint(3));

if(exist(filename,'file'))
    load(filename)
else
    [status,ncuts]=system(sprintf('ls -1 ../Differences/output/%s/data/cuts/ | wc -l',runname));
    ncuts=str2double(ncuts);
    [status, filedata]=system(sprintf('grep -h -e "^%3.6f %3.6f %3.6f" ../Differences/output/%s/data/cuts/*',refpoint(1), refpoint(2), refpoint(3), runname)); 
    data=cell2mat(textscan(filedata,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f'));

    inputvars={'Year','Month','Day','Hour','Min','Sec','Msec','Bx[nT]','By[nT]','Bz[nT]','Vx[km/s]','Vy[km/s]','Vz[km/s]','N[cm^(-3)]','T[Kelvin]'};

    inputs=dlmread(sprintf('../Differences/data/%s_IMF.txt',runname));

    for i=1:(ncuts-1)
        bininputs(i,:)=median(inputs((i-1)*30+1:i*30,:));
    end
    bininputs(ncuts,:)=median(inputs(ncuts-1)*30+1:end,:));
    
    save(filename,'data','inputs','bininputs','inputvars');
end

for ctest=8:15
   [~,~,~,~,corr]=IR(data(:,9),bininputs(:,ctest),0,3);
   fprintf('%s: %2.3f\n',inputvars{ctest},corr);
end

[~,~,~,~,corr]=IR(data(:,9),bininputs(:,8:15),0,3);
fprintf('All: %2.3f\n',corr);

plot(data(:,9)); %check for Bz flip

%grep -h -e "-200.000000 0.000000 -47.000000" ../Differences/output/Brian_Curtis_042213_2/data/cuts/*


    test=dlmread(sprintf('../Differences/output/%s/data/cuts/Step_70_Y_eq_0.txt',runname));
    x=unique(test(:,1));
    z=unique(test(:,3));
    d=reshape(test(:,8),length(x),[]);
    surf(x,z,d') %Make sure we're looking at the magnetosphere?
    
    
    %look at columns 8, 10, 11, 12?