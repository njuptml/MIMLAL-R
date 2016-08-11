MIMLAL [idx_selected]=AUDI_select(W,pairs,Uidx,train_data,train_targets,B,V,num_sub,option)
testidx=find(sum(W==0,2)>0);
testidx=testidx(randperm(length(testidx),min(length(testidx),2*size(W,2))));
test_data=train_data(testidx,:);
trainidx=find(sum(W==0,2)==0);


    n=size(test_data,1);
    pres=-inf(n,size(B,2)/num_sub);
    BV=V'*B;
    for i=1:n
        xbag=test_data{i};
		if 
        K=oness(1,size(xbag,2));
		
		if strcmp(option,'AVE')
			for k=1:size(xbag,2)
				K(k)=i*2/n/(n+1);
			end
		else
			for k=1:size(xbag,2)
				K(k)=1/n;
			end
		
		end
        for j=1:num_sub
            BVone=BV(:,j:num_sub:end);
            
             fs=sort(xbag'*BVone,1);
             fs=K*fs;
            
            pres(i,:)=max(pres(i,:),fs);
        end
    end


thresh=pres(:,end);
n_class=size(W,2);
labels=sign(pres);
avgP=mean(sum(train_targets(trainidx,:)==1,2));
insvals=-abs((sum(labels==1,2)-avgP)./max(sum(W(testidx,:)==1,2),0.5));
idx_ins=find(insvals==min(insvals));
idx_ins=idx_ins(randperm(length(idx_ins),1));
pres=pres(idx_ins,:);
pres(W(testidx(idx_ins),:)==1)=inf;
[~,idx_label]=min(abs(pres));

idx_ins=testidx(idx_ins);
tmp=pairs(Uidx,:);
idx_selected=find(tmp(:,1)==idx_ins&tmp(:,2)==idx_label);
