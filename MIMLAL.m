MIMLAL [query,p,r,f]=MIMLAL(train_data,train_targets,n_init,option)
% train_data: n*d | one row for an instance with d features
% train_targets: n*m | one row for an instance, -1 means irrelevant, 1 means relevant
% n_init: int | how many instance should be initial fully labeled
% query: int | selected instance-label pairs
% option: string | choose the pooling strategy | "AVE" for average and "ORD" for order-weighted
p=[];
f=[];
r=[];
query=[];
[n,m]=size(train_targets);
train_targets=[train_targets,2*ones(n,1)];

pairs=[];
for k=1:m
    pairs=[pairs;[(1:n)',ones(n,1)*k]];
end

idx=randperm(n,n_init);
W=zeros(n,m);
W(idx,:)=1;
Sidx=[];
init_data=train_data(idx(1:floor(n_init/6)),:);
init_targets=train_targets(idx(1:floor(n_init/6)),:);
test_data=train_data(idx(floor(n_init/6)+1:n_init),:);
test_targets=train_targets(idx(floor(n_init/6)+1:n_init),:);

for k=1:n_init
    Sidx=[Sidx,find(pairs(:,1)==idx(k))'];
end
Uidx=1:n*m;
Uidx(Sidx)=[];

n_init=length(Sidx);
n_iter=n*m-n_init;
n_batch=size(train_targets,2);

[B,V,AB,AV,Anum,trounds,costs,norm_up,step_size0,num_sub,lambda,opts,n_repeat]=MIMLAL_init(init_data,init_targets);

for tt=1:2
    [B,V,AB,AV,Anum,trounds]=MIMLA_train(W,train_data,train_targets,B,V,costs,norm_up,step_size0,num_sub,AB,AV,Anum,trounds,lambda,opts);
end
more=true;
ins=[];
count=1;
while(more)
    idx_selected=MIMLAL_select(W,pairs,Uidx,train_data,train_targets,AB/Anum,AV/Anum,num_sub,option);
    if((length(Sidx)-n_init+length(idx_selected))>=n_iter)
        idx_selected=idx_selected(1:n_iter+n_init-length(Sidx));
        more=false;
    end
    U=pairs(Uidx(idx_selected),:);
    for j=1:length(idx_selected)
        W(U(j,1),U(j,2))=1;
    end
    query=[query;U];
    Sidx=[Sidx,Uidx(idx_selected)];
    Uidx(idx_selected)=[];
    ins=[ins,unique(U(:,1))];
    if(length(ins)>=n_batch)
        for tt=1:n_repeat
            [B,V,AB,AV,Anum,trounds]=MIMLA_train(W(ins,:),train_data(ins,:),train_targets(ins,:),B,V,costs,norm_up,step_size0,num_sub,AB,AV,Anum,trounds,lambda,opts);
        end
        ins=[];
        pres=MIMLAL_test(test_data,AB/Anum,AV/Anum,num_sub);
        [ Precision,Recall,F1] = PRF1(pres,test_targets);
        p=[p,Precision];
        r=[r,Recall];
        f=[f,F1];
    end
    fprintf([num2str(count),' ']);
    if mod(count,10)==0
        fprintf('\n');
    end
    count=count+1;
end
end