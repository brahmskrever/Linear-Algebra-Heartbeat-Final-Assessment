% Clears screen
clc

% Loads patient 1
load("ecg problem/ecg1.mat")
ecg1 = ecg;
marker1 = marker;
time1 = time;

% Loads patient 2
load("ecg problem/ecg2.mat")
ecg2 = ecg;
marker2 = marker;
time2 = time;

% Loads patient 3
load("ecg problem/ecg3.mat")
ecg3 = ecg;
marker3 = marker;
time3 = time;

% Asks the user what patient they are looking for and only allows the availible
% patients
IsTrue = true;
while(IsTrue == true)
    prompt = 'What patient would you like to look at? Remember there are only 3 patients. ';
    Patientnumber = input(prompt);
    if(Patientnumber == 1)
        clc
        MAJOR_HT_RATE_INT(marker1,time1,ecg1)
        IsTrue = false;
    elseif (Patientnumber == 2)
        clc
        MAJOR_HT_RATE_INT(marker2,time2,ecg2)
        IsTrue = false;
    elseif(Patientnumber == 3)
        clc
        MAJOR_HT_RATE_INT(marker3,time3,ecg3)
        IsTrue = false;
    else
        disp('You have imputed a patient that does not exist')
    end
end

function MAJOR_HT_RATE_INT (marker,timer,ecg)
% Dummy Variables in this program i, j , k , l, m , n , p,

% Plots one wave of the ECG
plot(timer,ecg)
xlabel("time (s)");
ylabel("Signal Voltage (mv)");
title("ECG Signal")

% Ensures the graph window is optimal
if (length(ecg) == 32838)
    xlim([0.65 1.15]);
    ylim([-0.5 1.3]);
elseif (length(ecg)==65535)
    xlim([1.5 2.15]);
    ylim([-0.5 1.3]);
else
    xlim([0.9 1.9]);
    ylim([-0.5 1.3]);
end

% Plots red dots on the graph for better understanding of the points
hold on
plot(timer,ecg, "ro");

% This loop finds every time where there is a p, q, r, and t wave, in the
% ECG file
SUMHB = 0;
for i = 1:length(marker)
    if (marker(i,1)==1)
        P_WAVE_ZEROS(i,1) = timer(1,i-1);
    end
    
    if (marker(i,1)==2)
        Q_WAVE_ZEROS(i,1) = timer(1,i-1);
    end
    
    if (marker(i,1) == 3)
        SUMHB = SUMHB+1;
    end
    
    if (marker(i,1)==4)
        S_WAVE_ZEROS(i,1) = timer(1,i+1);
    end
    
    if (marker(i,1)==5)
        T_WAVE_ZEROS(i,1) = timer(1,i+1);
    end
end

% Unfortunately though, that loop leaves all of these variables with
%thousands of 0"s in it so these functions remove them from the arrays
P_WAVE_NO_ZEROS = nonzeros(P_WAVE_ZEROS);
Q_WAVE_NO_ZEROS = nonzeros(Q_WAVE_ZEROS);
S_WAVE_NO_ZEROS = nonzeros(S_WAVE_ZEROS);
T_WAVE_NO_ZEROS = nonzeros(T_WAVE_ZEROS);

% Depending on the graph, the first wave is random, so basically these if
%statements makesure that the graph starts at a full cycle
if(Q_WAVE_NO_ZEROS(1,1)< P_WAVE_NO_ZEROS(1,1))
    ORDERED_Q_WAVE = Q_WAVE_NO_ZEROS(2:length(d),1);
    ORDERED_P_WAVE = P_WAVE_NO_ZEROS(1:length(v)-1,1);
else
    ORDERED_Q_WAVE = Q_WAVE_NO_ZEROS;
    ORDERED_P_WAVE = P_WAVE_NO_ZEROS;
end

if(S_WAVE_NO_ZEROS(1,1)< Q_WAVE_NO_ZEROS(1,1))
    S_WAVE_ORDERED = S_WAVE_NO_ZEROS(2:length(S_WAVE_NO_ZEROS),1);
    Q_WAVE_ORDERED = Q_WAVE_NO_ZEROS(1:length(Q_WAVE_NO_ZEROS)-1,1);
else
    S_WAVE_ORDERED = S_WAVE_NO_ZEROS;
    Q_WAVE_ORDERED = Q_WAVE_NO_ZEROS;
end

if(T_WAVE_NO_ZEROS(1,1)< Q_WAVE_NO_ZEROS(1,1))
    ORDERED_T_WAVE = T_WAVE_NO_ZEROS(2:length(T_WAVE_NO_ZEROS),1);
    ORDERED_Q1_WAVE = Q_WAVE_NO_ZEROS(1:length(Q_WAVE_NO_ZEROS)-1,1);
    
else
    ORDERED_T_WAVE = T_WAVE_NO_ZEROS;
    ORDERED_Q1_WAVE = Q_WAVE_NO_ZEROS;
end

% These loops store the time between each interval in arrays
for(j = 1:length(ORDERED_P_WAVE))
    TIME_BETWEEN_QP(j) = ORDERED_Q_WAVE(j,1)-ORDERED_P_WAVE(j,1);
end

for(k = 1:length(S_WAVE_ORDERED))
    TIME_BETWEEN_QS(k) =  S_WAVE_ORDERED(k,1)- Q_WAVE_ORDERED(k,1);
end

for(l = 1:length(ORDERED_T_WAVE))
    TIME_BETWEEN_QT(l) = ORDERED_T_WAVE(l,1)-ORDERED_Q1_WAVE(l,1);
end

% Stating the variables before they goes in the loops
sumQP = 0;
sumQS = 0;
sumQT = 0;

% This adds up all of the time in each array to give the total time
for (m = 1:length(ORDERED_P_WAVE))
    sumQP = sumQP + TIME_BETWEEN_QP(m);
end

for (n = 1:length(S_WAVE_ORDERED))
    sumQS = sumQS + TIME_BETWEEN_QS(n);
end

for (p = 1:length(ORDERED_Q1_WAVE))
    sumQT = sumQT + TIME_BETWEEN_QT(p);
end

% This returns the avg time in each interval of the heartbeat
display("Your Heart Rate is "  + (SUMHB/timer(1,length(timer)) * 60) + " BPM ")
display("Your PR Interval is " + sumQP/length(TIME_BETWEEN_QP) + " seconds")
display("Your QRS Interval is " + sumQS/length(TIME_BETWEEN_QS) + " seconds")
display ("Your QT Interval is " + sumQT/length(TIME_BETWEEN_QT) + " seconds")

% Tells the user what conditions they have and if they should be worried [1]

% set up a dummy sum
Healthysum = 0;
% Heartbeat
if((SUMHB/timer(1,length(timer)) * 60)>100)
    display(append("Your heart rate is abnormally high and displays signs of" + newline + "tachycardia.You should consult a medical professional" + newline + "otherwise, you risk heart failure, stroke, or cardiac arrest"))
elseif((SUMHB/timer(1,length(timer)) * 60)< 100 && (SUMHB/timer(1,length(timer)) * 60) > 60)
    display(" Your heart rate is perfectly normal. You most likely take care" + newline + "of yourself!")
    Healthysum = Healthysum + 1;
else
    display(append("Your heart rate is abnormally low and displays signs" + newline + "of brachycardia. You should consult a medical professional" + newline + "otherwise, you risk cardiac arrest or sudden death"))
end

% PR Interval
if((sumQP/length(ORDERED_P_WAVE)) > 0.2)
    display(append("Your PR interval is larger than 0.2 seconds. Consult" + newline + " a medical proffesional immediately as you may have first degree" + newline + " heart block or trifasicular block "))
elseif ((sumQP/length(ORDERED_P_WAVE)) < 0.12)
    display(append("Your PR interval is less than 0.12 seconds. You" + newline + "may have Wolff-Parkinson-White syndrome, Lown-Ganong-Levine" + newline + "syndrome, Duchenne muscular dystrophy, type II glycogen storage disease," + newline + "or HOCM."))
else
    display ("Your PR interval is perfectly normal. You most likely take " + newline + "care of yourself!")
    Healthysum = Healthysum + 1;
end

% QRS Interval
if(sumQS/length(TIME_BETWEEN_QS) < 0.12)
    display("Your QRS interval is perfectly normal. You most likely take" + newline + "care of yourself!")
    Healthysum = Healthysum + 1;
else
    display (append("Your QRS interval is abnormally long. Conslut a medical proffesional" + newline + "because you may have right or left bundle branch block," + newline + "ventricular rhythm , hyperkalaemia,"))
end

% QT Interval
if((sumQT/length(ORDERED_Q1_WAVE))>0.35 && (sumQT/length(ORDERED_Q1_WAVE)) < 0.45)
    display("Your QT interval is perfectly normal. You most likely take" + newline + "care of yourself!")
    Healthysum = Healthysum + 1;
else
    display("Your QT interval is either too short or too long. Many diseases" + newline + "are associated with an abnormal QT interval and it is strongly" + newline + "recomended that you see a medical professional")
    % Overall health of the patient
end
if (Healthysum >= 3)
    display("Overall, You are a very healthy individual with minor" + newline + "issues.")
elseif(Healthysum == 2)
    display("Overall, You are a moderatly healthy to unhealthy individual," + newline + "consider changing your diet beofre major issues arrise.")
else
    display("Overall, You are a very unhealthy individual and need to talk to" + newline + "a medical proffesional to avoid life-threatening consequences.")
end

% Work Cited
% [1] S. G. Dean Jenkins, "Normal adult 12-lead ECG," ECGlibrary.com: Normal adult
% 12-lead ECG, 2017. [Online]. Available: https://ecglibrary.com/norm.php.
% [Accessed: 05-Dec-2020].
end
