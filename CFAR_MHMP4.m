function S_ = CFAR_MHMP4(Y,A,D,t,Z)

%% Initialization

% [~,P] = size(Y);
[N,L] = size(Z);

R = Z*Z';
R = sqrtm(inv(R));
Y = R*Y;
A = R*A;

D = [D ones(1,size(A,2)-length(D))];

x = 1-(1-t).^(1/size(A,2));
g = (x.^(-1/(L-N+2))-1)*(L+1)/(L-N+1);

S_ = [];
I_t = 1;
L = 1;
for s = 1:length(g)
   S_(s).S = [];
   S_(s).t = t(s);
end

%% Branching

B = [];
B.S = [];
B.proj = eye(size(Y,1));
B.fro = norm(Y,'fro')^2;
B.lvl = 0;
B.T = [];

for d = 1:length(D)

for i = 1:L

A_ = B(i).proj*A;
normA = sum(abs(A_).^2,1)';
normA(normA < 1e-12) = inf;

[~,I] = sort(abs(A_'*Y).^2./normA,'descend');

B_temp = tag(Y,A,B(i),I(1:D(d)));
B(end+1:end+length(B_temp)) = B_temp; 

end

B(1:L) = [];
S_k = [];

for l = 1:length(B)
    S_k(l,:) = sort(B(l).S);
end
   
[~,U,~] = unique(S_k,'rows');
B = B(sort(U));

[~,I] = min([B.fro]);

for f = I_t:length(g)

if min([B(I).T]) > g(f)
    S_(f).S = B(I).S;    
%     break
else
    I_t = f+1; 
%     break
end

end

if I_t > length(g)
    return
end

L = length(B);

end



end

% S_(1) = [];


    
function B = tag(Y,A,B_parent,I)
B = [];  
for i = 1:length(I)
    
    B(end+1).S = [I(i) B_parent.S];
    proj_ = B_parent.proj*A(:,I(i));
    B(end).proj = B_parent.proj - proj_*proj_'/norm(proj_)^2; 
    B(end).fro = norm(B(end).proj*Y,'fro')^2;
    B(end).lvl = length(B(end).S);    
    B(end).T = ASD(Y,A(:,B(end).S));
        
end
    
end

function T = ASD(Y,A)
    
    T = sum(abs(A\Y).^2,2);
    A_ = diag(inv(A'*A));
    
    T = abs(T./A_);


end

