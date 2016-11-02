% Copyright (c) 2012, Freescale Semiconductor
classdef AttitudeTrajectory < AbstractTrajectory
    % AttitudeTrajectory is derived from Abstract Trajectory.  It is used
    % to model orientation over time.  Typically, objects of this class
    % will also be associated with objects of type PositionTrajectory.
    % AttitudeTrajectory Properties:
    % O - Orientation timeseries (quaternion format)
    % AV - Angular Velocity timeseries
    % AA - Angular Acceleration timeseries
    % RAWAT = Raw data for the attitude trajectory
    % initial_orientation = just that, in quaternion form.  The identity
    % orientation = [1; 0; 0; 0].
    properties
        O;
        AV;
        AA;
        RAWAT;
        initial_orientation;
        initial_angular_velocity;
    end
    properties (Access=private)
        interpolation_method, type, computed;
    end
    methods (Access=private)
        function [traj] = init(traj, intp, time, data, type, units, tsName)
            % AttitudeTrajectory initializer
            % Input parameters are:
            % intp = interpolation method: 'linear' or 'spline'
            % data = array of raw input values
            % time = vector of time values
            % type = 1 of "angular acceleration', 'angular velocity' or 'quaternion'
            % units = units used for the raw data
            % tsName = time series name for the raw dadta
            traj.startTime=min(time);
            traj.endTime=max(time);
            traj.interpolation_method=intp;
            traj.type=type;
            traj.computed=0;
            ts = timeseries(data, time);
            ts.DataInfo.Units=units;
            ts.set('Name', tsName);
            traj.RAWAT=ts;
        end
    end
    methods
        function [traj] = AttitudeTrajectory(name)
            % AttitudeTrajectory constructor
            % Input parameters are:
            % name = string name for the time series.  Cosmetic only
            traj = traj@AbstractTrajectory(name);
            traj.type='none';
            traj.initial_angular_velocity = [0;0;0];
            traj.initial_orientation = [1; 0; 0; 0];  % initial rotation = none
        end
        function [traj] = quaternion_initialization(traj, time, data)
            [data] = shortest(data);
            % selective inversion of inputs to force shortest path
            traj = traj.init('slerp', time, data, 'orientation', 'quaternion', 'pwlPos');
        end
        function [traj] = set_av(traj, intp, time, data)
            
            % function [traj] = init(traj, intp, time, data, type, units, tsName)
            % AttitudeTrajectory initializer
            % Input parameters are:
            % intp = interpolation method: 'linear' or 'spline'
            % data = array of raw input values
            % time = vector of time values
            % type = 1 of "angular acceleration', 'angular velocity' or 'quaternion'
            % units = units used for the raw data
            % tsName = time series name for the raw dadta
            traj = traj.init(intp, time, data, 'angular velocity', 'radians/sec', 'pwlVel');
        end
        function [traj] = set_aa(traj, intp, time, data)
            traj = traj.init(intp, time, data, 'angular acceleration', 'radians/sec/sec', 'pwlAcc');
        end
        function [traj] = set_initial_av(traj, initial_av)
            traj.initial_angular_velocity = initial_av;
        end
        function [traj] = set_initial_orientation(traj, initial_or)
            traj.initial_orientation = initial_or;
        end
        
        % Begin definition of abstract classes from class "trajectory"
        function [traj] = compute(traj, inc1, inc2, filter_numerator, filter_denominator)
            % Compute detailed orientation information based on supplied inputs
            % both inc1 and inc2 are used for orientation interpolation
            % "standard Matlab filtering" can be applied if both filter_numerator and 
            % filter_denominator are not empty (filtering is skipped if either is empty).
            if (nargin<3)
                filter_numerator=[];
                filter_denominator=[];
            end
            if (inc2>0)
                % We will not interpolate inputs if inc2=0
                newTimePoints = traj.startTime:inc2:traj.endTime;
                myFuncHandle = @(new_time, time, data)...
                    interp1(time, data, new_time,...
                    traj.interpolation_method);
                myInterpObj = tsdata.interpolation(myFuncHandle);
            end
            if (strcmp(traj.type, 'none'))
                fprintf('There is NO ORIENTATION data to compute for this trajectory.\n');
            elseif (strcmp(traj.type, 'orientation'))
                [traj.O] = interpolate_orientations(traj, inc1, inc2, filter_numerator, filter_denominator);
                [traj.AV] = traj.differentiate_orientation();
                [traj.AA] = traj.differentiate(traj.AV, 'Angular Acceleration');
                traj.computed = 1;
            elseif (strcmp(traj.type, 'angular velocity'))
                if (inc2>0)
                    [traj.AV] = traj.copyTimeSeries(traj.RAWAT, 'Angular Velocity');
                    [traj.AV] = setinterpmethod(traj.AV,myInterpObj);
                    [traj.AV] = resample(traj.AV, newTimePoints);
                elseif (isempty(traj.AV))
                    error('Angular velocity time series has not been loaded nor interpolated from scratch.\n');
                end
                [traj.AV] = traj.optional_filter(traj.AV, filter_numerator, filter_denominator);
                [traj.O]  = traj.integrate_AV();
                [traj.AA] = traj.differentiate(traj.AV, 'Angular Acceleration');
                traj.computed = 1;
            elseif (strcmp(traj.type, 'angular acceleration'))
                if (inc2>0)
                    [traj.AA] = traj.copyTimeSeries(traj.RAWAT, 'Angular Acceleration');
                    [traj.AA] = setinterpmethod(traj.AA,myInterpObj);
                    [traj.AA] = resample(traj.AA, newTimePoints);
                elseif (isempty(traj.AA))
                    error('Angular acceleration time series has not been loaded nor interpolated from scratch.\n');
                end                
                [traj.AA] = traj.optional_filter(traj.AA, filter_numerator, filter_denominator);
                [traj.AV] = traj.integrate(traj.AA, 'Angular Velocity', 'radians/sec', traj.initial_angular_velocity);
                [traj.O]  = traj.integrate_AV();
                traj.computed = 1;
            else
                error('Invalid AttitudeTrajectory type found.  Results are invalid.');
            end
            % do a bit of housekeeping on the computed quaternions
            traj.O.Data = normalize_quaternion(traj.O.Data);
            traj.O.Data = fix_quaternion_polarity(traj.O.Data);
            
            traj.AA     = labelPoints(traj.RAWAT, traj.AA);
            traj.AV     = labelPoints(traj.RAWAT, traj.AV);
            traj.O      = labelPoints(traj.RAWAT, traj.O);
            traj.RAWAT  = labelPoints(traj.RAWAT, traj.RAWAT);
        end
        % Have included two almost equivalent functions.  There may be
        % differences in efficiency of one over the other in some circumstances
        function [newTraj] = retime_then_rotate_at(traj, inc, RM)
            newTraj = traj.retime_at(inc);
            newtraj = newTraj.rotate_at(RM);
        end
        function [newTraj] = rotate_then_retime_at(traj, inc, RM)
            newtraj = traj.rotate_at(RM);
            newTraj = newTraj.retime_at(inc);
        end
        function [newTraj] = retime_at(traj, inc)
            newTraj = traj;
            % we do not retime RAWAT data points
            if (~isempty(newTraj.O))
                newTraj.O  = traj.changeTimeIncrement(newTraj.O, inc);
                newTraj.O.Data = normalize_quaternion(newTraj.O.Data);
            end
            if (~isempty(newTraj.AV))
                newTraj.AV = traj.changeTimeIncrement(newTraj.AV, inc);
            end
            if (~isempty(newTraj.AA))
                newTraj.AA = traj.changeTimeIncrement(newTraj.AA, inc);
            end
        end
        function [newTraj] = rotate_at(traj, RM)
            newTraj = traj;
            if (~isempty(newTraj.RAWAT))
                newTraj.RAWAT = traj.rotate_in_place(newTraj.RAWAT, RM, ~strcmp(newTraj.type, 'orientation'));
            end
            if (~isempty(newTraj.O))
                newTraj.O  = traj.rotate_in_place(newTraj.O, RM, 0);
            end
            if (~isempty(newTraj.AV))
                newTraj.AV = traj.rotate_in_place(newTraj.AV, RM, 1);
            end
            if (~isempty(newTraj.AA))
                newTraj.AA = traj.rotate_in_place(newTraj.AA, RM, 1);
            end
        end
        function [newTs] = differentiate_orientation(traj)
            % differentiate_orientation assumes evenly spaced samples
            ts = traj.O;
            newName = 'Angular Velocity';
            data = ts.get('Data');
            time = ts.get('Time');
            
            [r, c] = size(data);
            dT = (time(2)-time(1));
            dq = differentiate( data, dT, 5 );
            for i=1:r
                R = quaternion_rates( data(i,:)', dq(i,:)' );
                newData(i,:) = R';
            end
            newTs = timeseries(newData, time);
            newTs.set('Name', newName);
            newTs.DataInfo.Units = 'radians/sec';
        end
        function [newTs] = integrate_AV(traj)
            % integrate Angular Velocity to get Orientation
            ts = traj.AV;
            data = ts.get('Data');
            time = ts.get('Time');
            
            [r, c] = size(data);
            dT = (time(2)-time(1));  % we assume that delta Time is constant
            previous_OR = traj.initial_orientation;
            for i=1:r
                incremental_rotation = quaternion_from_angular_rates( dT, data(i,:)' );
                orientation(i,:) = quaternion_multiplication(incremental_rotation, previous_OR);
                previous_OR(:) = orientation(i,:);
            end
            orientation = normalize_quaternion(orientation);  % Mostly just to ensure roundoff doesn't mess us up.
            newTs = timeseries(orientation, time);
            newTs.set('Name', 'Orientation');
            newTs.DataInfo.Units = 'quaternions';
        end
        
        function [] = plot_at_all(traj, Vin, dirName)
            if (nargin==2)
                dirName=''; % no jpegs will be saved
            end
            traj.plot_exponential_maps(dirName);
            traj.plot_rotation_sequence(Vin, dirName);
            traj.plot_raw_at_inputs(dirName);
            traj.plot_quaternion_values(dirName);
            traj.plot_AV_coords(dirName);
            traj.plot_AA_coords(dirName);
        end
        function [traj] = plot_exponential_maps(traj, dirName)
            if (traj.computed)
                figure;
                % str = fprintf('%s fit', traj.interpolation_method);
                xyz = traj.O.Data(:,2:4);
                [r, c] = size(xyz);
                for i=1:r
                    x(i)=traj.O.Data(i,2)*traj.O.Data(i,1);
                    y(i)=traj.O.Data(i,3)*traj.O.Data(i,1);
                    z(i)=traj.O.Data(i,4)*traj.O.Data(i,1);
                end
                plot3(x, y, z);
                grid on;
                hold on;
                
                if(strcmp(traj.type, 'orientation'))
                    [r, c] = size(traj.RAWAT.Data);
                    if (r<21)
                        for i=1:r
                            rx(i) = traj.RAWAT.Data(i,2)*traj.RAWAT.Data(i,1);
                            ry(i) = traj.RAWAT.Data(i,3)*traj.RAWAT.Data(i,1);
                            rz(i) = traj.RAWAT.Data(i,4)*traj.RAWAT.Data(i,1);
                        end
                        plot3(rx, ry, rz, 'ro', 'MarkerFaceColor', 'r');
                        grid on;
                    end
                else
                    X=mean(get(gca,'Xlim'));
                    Y=mean(get(gca,'Ylim'));
                    Z=mean(get(gca,'Zlim'));
                    text(X,Y,Z,'Input timestamp markers are too numerous to show');
                end
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                title('Orientation displayed as exponential maps');
                grid on;
                hold off;
                if (nargin>1)
                            savePlot( dirName, '1-0_traj_exponential_maps' );
                end
            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [traj] = plot_rotation_sequence(traj, Vin, dirName)
            if (traj.computed)
                figure;
                [r, c] = size(traj.O.Data);
                for i=1:r
                    q = traj.O.Data(i,1:4);
                    O(i,:) = quaternion_point_rotation( q, Vin )';
                end
                plot3(O(:,1), O(:,2), O(:,3), '.');
                hold on;
                [r, c] = size(traj.RAWAT.Data);
                if ((r<21)&&strcmp(traj.type, 'orientation'))
                    for i=1:r
                        q = traj.RAWAT.Data(i,1:4);
                        Or(i,:) = quaternion_point_rotation( q, Vin )';
                    end
                    plot3(Or(:,1), Or(:,2), Or(:,3), 'ro', 'MarkerFaceColor', 'r');
                    m=0; % m is the number of discrete physical points brought out in the program input
                    for i=1:r
                        found=0;
                        for j=1:m
                            if (1==points_match(locs(j,:), Or(i,:)))
                                addition = sprintf(', %6.3f', traj.RAWAT.Time(i));
                                CSA{j}=strcat(CSA{j}, addition);
                                found=1;
                                break;
                            end
                        end
                        if (~found)
                            m=m+1;
                            locs(m,:) = Or(i,:);
                            time = traj.RAWAT.Time(i);
                            s = sprintf('\\leftarrow Time=%6.3f', time );
                            CSA{m}=cellstr(s);
                        end
                    end
                    for i=1:m
                        text(locs(i,1), locs(i,2), locs(i,3), CSA{i});
                    end
                else
                    X=mean(get(gca,'Xlim'));
                    Y=mean(get(gca,'Ylim'));
                    Z=mean(get(gca,'Zlim'));
                    text(X,Y,Z,'Input timestamp markers are too numerous to show');
                end
                s = sprintf('[%6.3f %6.3f %6.3f] Rotated by Input Quaternions', Vin(1), Vin(2), Vin(3));
                title(s);
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                grid on;
                hold off;
                if (nargin>2)
                            savePlot( dirName, '1-1_traj_rotation_sequence' );
                end

            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [traj] = plot_raw_at_inputs(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.RAWAT);
                grid on;
                str = sprintf('Raw Input Data (%s)', traj.type);
                title(str);
                if (strcmp(traj.type, 'orientation'))
                    legend('W', 'X', 'Y', 'Z');
                else
                    legend('X', 'Y', 'Z');
                end
                if (nargin>1)
                    savePlot( dirName, '1-2_traj_RAWAT' );
                end
                
            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [traj] = plot_quaternion_values(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.O);
                grid on;
                title('Orientation Data');
                legend('W', 'X', 'Y', 'Z');
                if (nargin>1)
                    savePlot( dirName, '1-3_traj_O' );
                end
            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [traj] = plot_AV_coords(traj, dirName)
            if (traj.computed)
                figure;
                plot(traj.AV);
                grid on;
                legend('Vx=dX', 'Vy=dY', 'Vz=dZ');
                title('Angular Velocity Data');
                if (nargin>1)
                    savePlot( dirName, '1-4_traj_AV' );
                end
            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [traj] = plot_AA_coords(traj, dirName)
            if (traj.computed)                
                figure;
                plot(traj.AA);
                grid on;
                legend('Ax=dX^2', 'Ay=dY^2', 'Az=dZ^2');
                title('Angular Acceleration Data');
                if (nargin>1)
                    savePlot( dirName, '1-5_traj_AA' );
                end
            else
                error('You must compute your attitude trajectory before plotting it.');
            end
        end
        function [] = data_dump(traj, dirName, refFrame)
            if (nargin<3)
                refFrame = Env.NED;
                fprintf('WARNING: Assuming NED Reference Frame as default for Euler Angle generation\n');
            end
            % dirName = output directory name
            if ((7==exist(dirName)) || mkdir(dirName))
                var=traj.O.Time(:)     ; save(fullfile(dirName,'TRUE_time.dat'), '-ascii', 'var');
                var=traj.AV.Data(:,1:3); save(fullfile(dirName,'TRUE_AV.dat'), '-ascii', 'var');
                var=traj.O.Data(:,1:4) ; save(fullfile(dirName,'TRUE_quaternion.dat'), '-ascii', 'var');
                [r,c] = size(traj.O.Data);
                for i=1:r
                    q = traj.O.Data(i,:);
                    rm  = RM_from_quaternion( q );
                    RM(i,1:3) = rm(1,1:3);
                    RM(i,4:6) = rm(2,1:3);
                    RM(i,7:9) = rm(3,1:3);
                end
                save(fullfile(dirName,'TRUE_rotations.dat'), '-ascii', 'RM');

                % CREATE EULER ANGLES FILE:
                [EUA] = quaternions_to_eulers(traj.O.Data, refFrame);
                save(fullfile(dirName,'TRUE_EulerAngles.dat'), '-ascii', 'EUA');

            end
        end

        function [] = animate_rotation(traj, inc)
            figure;
            %    1 2 3 4 5 6 7 8 9
            x = [0;1;1;0;0;1;1;0;.5];
            y = [0;0;1;1;0;0;1;1;.5];
            z = [0;0;0;0;1;1;1;1;1.25];
            x = (x - 0.5)/4;
            y = (y - 0.5)/4;
            z = z - 0.5;
            
            FA = 0.9;
            vertices = [ x y z];
            faces = [1 2 3 4; ...
                5 6 7 8; ...
                1 5 8 4; ...
                2 6 7 3; ...
                1 5 6 2; ...
                4 8 7 3; ...
                5 6 9 NaN; ...
                6 7 9 NaN; ...
                7 8 9 NaN; ...
                5 8 9 NaN];
            
                cdata = [
                    0 0 0;    % black
                    1 0 0;    % red
                    0 1 0;    % green
                    0 1 1;    % turquoise
                    .5 .5 .5; % gray
                    1 0 0;    % red
                    .5 .5 .5; % gray
                    0 1 1;    % turquoise
                    1 0 0;    % red
                    0 1 0];   % green
                       
            q = traj.O.Data;
            l=length(q);
            for j = 1:inc:l
                q0 = q(j,1);
                q1 = q(j,2);
                q2 = q(j,3);
                q3 = q(j,4);
                theta = acos(q0);
                if (j<l)
                    clf; % This keeps us from one last, undesired, erase.
                end
                view(3);
                axis([-.5 .5 -.5 .5 -.5 .5 0 1]);
                h = patch('Vertices', vertices,'Faces',faces,'FaceVertexCData',cdata, ...
                    'FaceColor','flat','EraseMode','normal');
                rotate(h,[q1 q2 q3],360*theta/pi);
                xlabel('X'); ylabel('Y'); zlabel('Z');
                pause(0.001);
            end
        end
        % end of public method definitions
    end
    methods (Access=private)      
        function [ts] = interpolate_orientations(traj, inc1, inc2, filter_numerator, filter_denominator)
            % we use a two phase process to interpolate between
            % orientations.  First a slerp-based algorithm is used to
            % build a 1st order estimate, then a spline interpolation is
            % used to smooth and retime the sequence.  This seems to give
            % the most "esthetically pleasing" results.
            if (nargin<3)
                filter_numerator=[];
                filter_denominator=[];
            end
            data=traj.RAWAT.Data;
            time=traj.RAWAT.Time;
            [time, data] = slerp(time, data, inc1);
            if (inc2>0)
                newTime = min(time):inc2:max(time);
                data = interp1(time, data, newTime, 'spline');
            else
                newTime = time;
            end
            if ~(isempty(filter_numerator) || isempty(filter_denominator))
                data = filtfilt(filter_numerator, filter_denominator, data);
            end
            [data] = normalize_quaternion(data);
            ts = timeseries(data, newTime);
            ts.set('Name', 'orientation');
        end
    end
    
end

% The following three functions are only expected to be needed from within
% the AttitudeTrajectory class, and are therefore included locally here.

function [data] = shortest(data)
% shortest(rawData) checks the sequence of quaternions in the input
% data stream and (when necessary) inverts elements of the sequence
% to ensure that we always travel the shortest distance between two
% points.  This works because the inverse of a rotation quaternion
% ends up at the same point, but by going in the opposite direction
% about 360 degrees.
% This is done in the data up front to ensure that we don't have to
% worry about it downstream.
[r,c] = size(data);
for i=1:r-1
    q0 = data(i,:);
    q1 = data(i+1,:);
    dotp = dot(q0, q1);
    if (dotp<0)
        % fprintf('Inverting input orientation #%d previously (%f %f %f %f) to force shortest path', ...
        %    i+1, data(i+1,1), data(i+1,2), data(i+1,3), data(i+1, 4));
        data(i+1,:) = -1*data(i+1,:);
    end
end
end

function [newTime, newData] = slerp(time, data, inc);
% slerp = Slerp Interpolation
% This function is responsible for calling Slerp to fill in the
% holes between original quaternions.  It may be called
% multiple times so that I can add filtering at different time
% granularities
[r, c] = size(data);
start=time(1);
stop=time(r);
j=0;
for i=1:r-1
    %fprintf ('Interpolating between points %d and %d\n', i, i+1);
    q0 = data(i,:);
    q1 = data(i+1,:);
    t0 = time(i);
    t1 = time(i+1);
    j = j+1;
    newData(j,:) = q0;
    newTime(j) = t0;
    t=t0+inc;
    while (t<t1)
        j=j+1;
        newData(j,:) = simpleSlerp(q0, q1, t0, t1, t);
        newTime(j) = t;
        t = t+inc;
    end
end
j=j+1;
newData(j,:) = q1(:);
newTime(j) = t1;
end

function [q] = simpleSlerp(q0, q1, t0, t1, tnew)
% This is the standard SLERP function popularized by Shoemake
% References include:
%   "Quaternions" by Ken Shoemake
%   "Animating Rotation with Quaternion Curves" by Ken Shoemake
%   "Quaternions and SLERP" by Verena Kremer
%   "Understanding Slerp, Then not using it", by Jonathan Blow
% I believe there's at least one error in Blow's writeup.  I use
% his concept of a "threshold" for very small angles, but otherwise
% follow the classic Shoemake terminology.
threshold = 0.999;
dotp = dot(q0, q1);
% Some forms of the slerp function selectively invert either q0
% or q1 to force the shortest path between two orientations.  I
% do the same thing in the constructor for the
% AttitudeTrajectory class, so it does not need to be done
% here.
%
% Shoemake restricts "t" to be between 0 and 1.  I removed that
% restriction by allowing a general range and then internally
% normalizing back to Shoemake's definition.
t = (tnew-t0)/(t1-t0);

if (abs(dotp) > threshold)
    % for very small angles, just do a linear interpolation
    q = q0 + t*(q1-q0);
else
    % do Shoemake Slerp
    dotp = clamp(dotp, 1);
    omega = acos(dotp);
    sin_omega = sin(omega);
    k0=sin((1-t)*omega)/sin_omega;
    k1=sin(t*omega)/sin_omega;
    q = q0*k0 + q1*k1;
end
end


