%comment these lines to use pre-trained model;
[ft,RMSEs] = model(75);
writematrix(ft);
%
A = readmatrix("ft.txt");
UniversityofAlabamaenrollments = importfile("C:\Users\xalan\MATLAB\Projects\pso_fts\University of Alabama enrollments.csv", [2, Inf]);
ryears = sortrows(UniversityofAlabamaenrollments{:,1});
rstudents = sortrows(UniversityofAlabamaenrollments{:,6});
%n = 50
[m,n] = size(A); %get prediction size from model
years = ryears(1:n);
students = rstudents(1:n);
D1 = 2000;
D2 = 2000;
Dmax = max(students);
Dmin = min(students);

%FORECASTING WITH OPTIMIZED P, select best 1 out of 10 in best particles group
RMSEbest = Dmax;
% Derive GBest from model ft matrix
GBest = zeros(n-1,1);
for id = 1:10
	if RMSEs(id) < RMSEbest
        RMSEbest = RMSEs(id);
        GBest = A(id,:);
	end
end
%disp(Gbest);
%Here I use 2000 as D1 and D2
xMin = Dmin - D1;
xMax = Dmax + D2;
% Create spaces for new data with best partition trained.
U = zeros(n-1,2);
for id = 1:n-1
    U(id,1) = GBest(id);
    U(id,2) = GBest(id + 1);
end
%disp(U);
%Array of values and its best interval with probability 
%from best partition.
BInterval = zeros(n,5);
for idx = 1:n
    for jdx = 1:n-1
        BInterval(idx,2) = students(idx);  
        if U(jdx,1)<= students(idx) && students(idx)<=U(jdx,2)
            BInterval(idx,1) = jdx;
            BInterval(idx,3) = (students(idx) - U(jdx,1))/(U(jdx,2) - U(jdx,1));
            BInterval(idx,4) = U(jdx,1);
            BInterval(idx,5) = U(jdx,2);
        end
    end
end
%disp(Interval);
LR = zeros(n-1,4);
for idx = 2:n
    LR(idx-1,1) = BInterval(idx - 1,1);
    LR(idx-1,2) = BInterval(idx,1);
    LR(idx-1,3) = BInterval(idx,4);
    LR(idx-1,4) = BInterval(idx,5);
end
%disp(LR);
%Here we refrain from creating group vector as we use 'for loop' to chack
%ui->uk in LR instead of calling the group vector.
%LRG = unique(LR,'rows');
%disp(LRG);
Forecast = zeros(n+1,5);
%tesing data
for idx = 1:n
    LR_Count = 0;
    Sum_Prob = 0;
    Forecast(idx,1) = years(idx);
    Forecast(idx,2) = BInterval(idx,1);
    for jdx = 1:n-1
        %Current interval for this year
          
        %if this year interval has LR
        if LR(jdx,1) == BInterval(idx,1)
            LR_Count = LR_Count + 1;
            Prob = (BInterval(idx,3)*(LR(jdx,4) - LR(jdx,3))) + LR(jdx,3);
            Sum_Prob = Sum_Prob + Prob;
        end
    end
    if LR_Count == 0
        %if this year interval has no LR
        %If xid, j < (Dmin ? D1), then let
        if BInterval(idx,1) < LR(jdx,1)
            Prob = (Dmin + D1) + (0.5 * rand())*((Dmax + D2)-(Dmin - D1));
            Sum_Prob = Sum_Prob + Prob;
        end
        %If xid, j > (Dmax + D2), then let
        if BInterval(idx,1) > LR(jdx,1)
            Prob = (Dmax - D1) + (0.5 * rand())*((Dmax + D2)-(Dmin - D1));
            Sum_Prob = Sum_Prob + Prob;
        end   
    end
    Forecast(idx,3) = BInterval(idx,2); %actual value ft
    Forecast(idx + 1,4) = Sum_Prob/LR_Count; %forecast value Ft
    Forecast(idx,5) = BInterval(idx,3); %probability
    Forecast(idx,6) = (Forecast(idx,4) - Forecast(idx,3))^2; %square error
    Forecast(idx,7) = (Forecast(idx,4) - Forecast(idx,3)); %error
    Forecast(idx,8) = (Forecast(idx,4) - Forecast(idx,3))*100/Forecast(idx,3); %percentage error
end
format bank;
F = Forecast(1:n,:);
Ft = Forecast(2:n-1,3:4); %forecast value Ft and Actual value
disp(years(2:n-1));
plot(years(2:n-1),Ft);
RMSE = sqrt(sum(Forecast(2:n-1,6),1)/n-1);
disp(RMSE);