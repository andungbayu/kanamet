function output=waterbalance(monthly_precip,monthly_PET,sto)


% begin linearize data
monthly_precip=transpose(monthly_precip);
monthly_PET=transpose(monthly_PET);
monthly_precip=monthly_precip(:);
monthly_PET=monthly_PET(:);

% calculate P-PET
diff_P_PET=monthly_precip-monthly_PET;

% calculate monthly AWL difference
mAWL=zeros(size(diff_P_PET));
mAWL(diff_P_PET>=0)=0;
mAWL(diff_P_PET<0)=abs(diff_P_PET(diff_P_PET<0));

% calculate AWL
AWL=zeros(size(mAWL));
for i=2:length(mAWL),
    if mAWL(i-1)==0 && mAWL(i)>0,
        AWL(i)=mAWL(i);
    elseif mAWL(i-1)>0 && mAWL(i)>0,
        AWL(i)=mAWL(i)+AWL(i-1);
    elseif mAWL(i-1)>0 && mAWL(i)==0,
         AWL(i)=0;
    end
end

% calculate St
St=zeros(size(AWL));
for i=1:length(AWL),
    if AWL(i)==0,
        St(i)=sto;
    else
        St(i)=sto.*exp(-1*(AWL(i)./sto));
    end
end

% calculate deltaSt
deltaSt=zeros(size(St));
for i=1:length(St),
    if i==1,
        deltaSt(i)=St(i)-St(length(St));
    else
        deltaSt(i)=St(i)-St(i-1);
    end
end

% calculate EA
EA=zeros(size(deltaSt));
for i=1:length(deltaSt),
    if diff_P_PET(i)>=0,
        EA(i)=monthly_PET(i);
    else
        EA(i)=monthly_precip(i)+abs(deltaSt(i));
    end
end

% calculate surplus deficit
surplus=(monthly_precip-monthly_PET)-deltaSt;
%deficit=monthly_PET-EA;

% create output
nyear=length(surplus)./12;
output=reshape(surplus,[12,nyear]);
output=transpose(output);

end

