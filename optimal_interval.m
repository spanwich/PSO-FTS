function [F,Ft,RMSE,U,V,Fnext,r] = optimal_interval(D1,D2,years,students,n)
    %PSO-Based Optimal Partition Algorithm
    Dmax = max(students);
    Dmin = min(students);

    rng('shuffle','twister');
    xMin = Dmin - D1;
    xMax = Dmax + D2;
    %Step 1: Randomly generate m particles xid where xmin ? xid, j ? xmax, 1 ? j ? n ? 1,
    xid = (xMax-xMin).*rand(n-1,1) + xMin;
    r = sortrows(xid);
    %r_range = [min(r) max(r)]; for checking x range
    %disp(r_range);


    Vmin = (-0.2*(xMax-xMin))/2;
    Vmax = (0.2*(xMax-xMin))/2;
    V = (Vmax-Vmin).*rand(n-1,1) + Vmin;
    %v_range = [min(v) max(v)]; for checking v range
    %% 
    %Intervals
    U = zeros(n,2);
    U(1,1) = xMin;
    U(1,2) = r(1);
    for id = 2:n-2
        U(id,1) = r(id - 1);
        U(id,2) = r(id);
    end
    U(n,1) = r(n-1);
    U(n,2) = xMax;
    %Array of values and its interval with probability
    Interval = zeros(n,5);
    for idx = 1:n
        for jdx = 1:n
            Interval(idx,2) = students(idx);  
            if U(jdx,1)<= students(idx) && students(idx)<=U(jdx,2)
                Interval(idx,1) = jdx;
                Interval(idx,3) = (students(idx) - U(jdx,1))/(U(jdx,2) - U(jdx,1));
                Interval(idx,4) = U(jdx,1);
                Interval(idx,5) = U(jdx,2);
            end
        end
    end
    %disp(Interval);
    %Relations ui -> uk with upper and lower bound of uk
    LR = zeros(n-1,4);
    %LR(1,1) = Interval(1,1);
    %LR(1,2) = Interval(2,1);
    for idx = 2:n
        LR(idx-1,1) = Interval(idx - 1,1);
        LR(idx-1,2) = Interval(idx,1);
        LR(idx-1,3) = Interval(idx,4);
        LR(idx-1,4) = Interval(idx,5);
    end
    %disp(LR);
    %Here we refrain from creating group vector as we use 'for loop' to chack
    %ui->uk in LR instead of calling the group vector.
    %LRG = unique(LR,'rows');
    %disp(LRG);
    Forecast = zeros(n+1,5);
    for idx = 1:n
        LR_Count = 0;
        Sum_Prob = 0;
        Forecast(idx,1) = years(idx);
        Forecast(idx,2) = Interval(idx,1);
        for jdx = 1:n-1
            %Current interval for this year

            %if this year interval has LR
            if LR(jdx,1) == Interval(idx,1)
                LR_Count = LR_Count + 1;
                Prob = (Interval(idx,3)*(LR(jdx,4) - LR(jdx,3))) + LR(jdx,3);
                Sum_Prob = Sum_Prob + Prob;
            end
        end
        if LR_Count == 0
            Sum_Prob = max(LR(:,4));
            LR_Count = 1;
        end
        Forecast(idx,3) = Interval(idx,2); %actual value ft
        Forecast(idx + 1,4) = Sum_Prob/LR_Count; %forecast value Ft
        Forecast(idx,5) = Interval(idx,3); %probability
        Forecast(idx,6) = (Forecast(idx,4) - Forecast(idx,3))^2; %square error
        Forecast(idx,7) = (Forecast(idx,4) - Forecast(idx,3)); %error
        Forecast(idx,8) = (Forecast(idx,4) - Forecast(idx,3))*100/Forecast(idx,3); %percentage error
    end
    %Step 2.1 : For each iteration, compute the objective value of each particle id, 
    F = Forecast(1:n,:);
    Ft = Forecast(1:n,3:4); %forecast value Ft and Actual value
    Fnext = Forecast(n+1,4);
    RMSE = sqrt(sum(Forecast(:,6),1)/n-1);
end