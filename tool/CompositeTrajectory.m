% Copyright (c) 2012, Freescale Semiconductor
classdef CompositeTrajectory < PositionTrajectory  & AttitudeTrajectory
    % This is the wrapper class for all trajectory functions
    
    properties
    end
    
    methods
        function [traj] = CompositeTrajectory(name)
            traj = traj@AttitudeTrajectory(name);
            traj = traj@PositionTrajectory(name);
        end
        function [traj] = compute(traj, inc1, inc2, filter_numerator, filter_denominator)
            traj = traj.compute@PositionTrajectory(inc2, filter_numerator, filter_denominator);
            traj = traj.compute@AttitudeTrajectory(inc1, inc2, filter_numerator, filter_denominator);
        end
        % retime_then_rotate and rotate_then_retime vary only in the order
        % of operations.  One or the other may be more efficient, depending
        % upon whether the retime sequence results in fewer or more data
        % points.
        function [newTraj] = retime_then_rotate(traj, inc, RM);
            newTraj = traj.retime_then_rotate_at(inc, RM);
            newTraj = newTraj.retime_then_rotate_pt(inc, RM);
        end
        function [newTraj] = rotate_then_retime(traj, inc, RM);
            newTraj = traj.rotate_then_retime_at(inc, RM);
            newTraj = newTraj.rotate_then_retime_pt(inc, RM);
        end
        function [newTraj] = rotate(traj, RM);
            newTraj = traj.rotate_at(RM);
            newTraj = newTraj.rotate_pt(RM);
        end
        function [newTraj] = retime(traj, inc);
            newTraj = traj.retime_at(inc);
            newTraj = newTraj.retime_pt(inc);
        end
        function [] = plot_at(traj, Vin, dirName)
            if (nargin==1)
                dirName='';
            end
            traj.plot_at_all(Vin, dirName);
        end
        function [] = plot_pt(traj)
            if (nargin==1)
                dirName='';
            end
            traj.plot_pt_all(dirName);
        end
        function [] = plot_all(traj, Vin, dirName)
            if (nargin==2)
                dirName='';
            end
            traj.plot_at_all(Vin, dirName);
            traj.plot_pt_all(dirName);
            traj.plot_orientation_and_position(Vin, dirName);
        end
        function [] = plot_orientation_and_position(traj, Vin, dirName)
            if (nargin==2)
                dirName='';
            end
            traj.plot_3D_trajectory('');
            title('Position and Orientation');
            hold on;
            axis manual;
            
            x_limits = get(gca,'Xlim');
            y_limits = get(gca,'Ylim');
            z_limits = get(gca,'Zlim');
            x2 = (x_limits(2)-x_limits(1))^2;
            y2 = (y_limits(2)-y_limits(1))^2;
            z2 = (z_limits(2)-z_limits(1))^2;
            sf = (1/20) * [sqrt(x2); sqrt(y2); sqrt(z2)];
            sf = min(sf);
            
            [r,c] = size(traj.O.Data);
            if (r>400)
                inc = round(r/200);
            elseif (r>200)
                inc = round(r/100);
            else
                inc = 1;
            end
            j=0;
            for i=1:inc:r
                j=j+1;
                q = traj.O.Data(i,:)';
                [ vector ] = sf * quaternion_point_rotation( q, Vin );
                x(1) = traj.P.Data(i,1);
                y(1) = traj.P.Data(i,2);
                z(1) = traj.P.Data(i,3);
                x(2) = x(1)+ vector(1);
                y(2) = y(1) + vector(2);
                z(2) = z(1)+ vector(3);
                line(x,y,z,'Color', 'm');
            end
            if (nargin==2)
                savePlot( dirName, '5-0_traj_3D_trajectory_and_orientation' );
            end
            hold off;
            axis auto;
        end
        function [ok] = precheck(traj)
            max_pt_time = max(traj.RAWPT.time);
            max_av_time = max(traj.RAWAT.time);
            if (max_pt_time == max_av_time)
                if (max_pt_time==traj.endTime)
                    ok=true;
                else
                    fprintf('ERROR: traj.endTime does not match time series end times.\n');
                    ok=false;
                end
            else
                fprintf('ERROR: Position and attitude trajectories do not have the same max time value.\n');
                fprintf('Position has max time = %f\n', max_pt_time);
                fprintf('Attitude has max_time = %f\n', max_at_time);
                ok=false;
            end
        end
        function [ok] = self_check(traj)
            max_pt_time = max(traj.P.time);
            max_av_time = max(traj.AV.time);
            ok=true;
            if (traj.computed)
                if (max_pt_time ~= max_av_time)
                    fprintf('ERROR: Position and attitude trajectories do not have the same max time value.\n');
                    fprintf('Position has max time = %f\n', max_pt_time);
                    fprintf('Attitude has max_time = %f\n', max_at_time);
                    ok=false;
                end
            else
                error('You must compute your position trajectory before plotting it.');
                ok=false;
            end
        end
        function [] = run_animation(traj, f, h1, sf, inc, mn, mx, dirName)
            h2=subplot(1,2,2);
            a = avatar2();
            orientations = traj.O.Data;
            l=length(orientations);
            [ makeAVI, writerObj ] = startAVI( dirName, 'animation.avi' );
            for j = 1:inc:l
                q = orientations(j,:);
                location = (traj.P.Data(j,:))';
                subplot(h1);
                if (j<l)
                    cla; % This keeps us from one last, undesired, erase.
                end
                plot3(traj.P.Data(:,1), traj.P.Data(:,2), traj.P.Data(:,3));
                title('3D trajectory');
                axis([mn mx mn mx mn mx 0 1]);
                a.draw(q, sf, traj.P.Data(j,:)');
                grid on;
                xlabel('X'); ylabel('Y'); zlabel('Z');
                
                subplot(h2);
                axis([-1 1 -1 1 -1 1 0 1]);
                if (j<l)
                    cla; % This keeps us from one last, undesired, erase.
                end
                set(h2, 'Visible', 'off');
                view(3);
                a.draw(q, 1, [0;0;0]);
                pause(0.001);
                
                if (makeAVI==1)
                    frame = getframe(f);
                    writeVideo(writerObj,frame);
                end
            end
            if (makeAVI==1)
                close(writerObj);
            end
        end
        function rerun_callback(src, eventData, traj, f, h1, sf, inc, mn, mx, dirName)
            run_animation(traj, f, h1, sf, inc, mn, mx, '');
        end
        function [] = animate(traj, inc, dirName)
            if (nargin<3)
                dirName='';
            end
            f = figure('Visible','on','MenuBar', 'figure','Position',[100,100,600,400]);
            
            h1=subplot(1,2,1);
            plot3(traj.P.Data(:,1), traj.P.Data(:,2), traj.P.Data(:,3));
            x = get(gca,'Xlim');
            y = get(gca,'Ylim');
            z = get(gca,'Zlim');
            mx = max([x(2); y(2); z(2)]);
            mn = min([x(1); y(1); z(1)]);
            axis([mn mx mn mx mn mx 0 1]);
            sf = abs(mx-mn)/10;
            view(3);
            
            % Assign the GUI a name to appear in the window title.
            set(f,'Name','TSim Trajectory Animation')
            
            traj.run_animation(f, h1, sf, inc, mn, mx, dirName)
            
            sb = uicontrol('Style','pushbutton','String','Re-Run',...
                'FontWeight', 'bold', 'FontSize', 12, ...
                'Position',[390,50,100,25], 'Callback', ...
                {@rerun_callback, traj, f, h1, sf, inc, mn, mx, dirName});
            set([f sb],'Units','normalized');
            
        end % function
        function [] = data_dump(traj, dirName, refFrame)
            % dirName = output directory name
            if (nargin<3)
                refFrame = Env.NED;
                fprintf('WARNING: Assuming NED Reference Frame as default for Euler Angle generation\n');
            end
            traj.data_dump@PositionTrajectory(dirName);
            traj.data_dump@AttitudeTrajectory(dirName, refFrame);
        end

    end
    
end

