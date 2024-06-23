function [] = plotEegConnectionMap(chanlocs,conn)
%PLOTEEGCONNECTIONMAP plots the EEG connectivity topo map
%  Inputs:
%   chanlocs - EEG.chanlocs structure with channel locations (x and y)
%   conn - connectivity matrix - directed.
nrEl=numel(chanlocs);

if min(size(conn)==[nrEl nrEl],[],"all")<1
    if numel(conn)==nrEl*nrEl
        warning("Reshaping of the connectivity matrix needed!");
        conn=reshape(conn,[nrEl nrEl]);
    else
        error("Invlaid size of the connectivity matrix!");
    end
end

figure
hold on;
colormap(jet);
conn(conn<0)=0;
conn=conn.^2;
connsc=conn/max(conn(:));
rgb=sky; %jet

[connsrt, index] = sort(connsc(:),'ascend');
[e1,e2]=ind2sub([nrEl nrEl],index);
for i=1:nrEl*nrEl
    if e2(i)~=e1(i)
        w=connsrt(i);
        arrow([chanlocs(e2(i)).X,chanlocs(e2(i)).Y], [chanlocs(e1(i)).X,chanlocs(e1(i)).Y], 'Color',rgb(floor(255*w)+1,:),'LineWidth',4*w+0.001, 'Length',5+5*w);
        %quiver(chanlocs(e1(i)).X,chanlocs(e1(i)).Y, chanlocs(e2(i)).X-chanlocs(e1(i)).X, chanlocs(e2(i)).Y-chanlocs(e1(i)).Y, 0, 'Color',rgb(floor(255*w)+1,:),'LineWidth',5*w)
    end
end

%colormap(rgb); colorbar

for i = 1 : nrEl             %% plotting nodes
    w=connsc(i,i);
    plot(chanlocs(i).X, chanlocs(i).Y, 'ko' , 'MarkerSize', 2+23*w, 'MarkerFaceColor', rgb(floor(255*w)+1,:) );
    text(chanlocs(i).X+3+3*w, chanlocs(i).Y+1, chanlocs(i).labels, 'FontSize', 12);
end
view([270 90]);             %% rotating to vertical view
axis equal; axis off;
set(gcf, 'units','normalized','outerposition',[0 0 1 1]) %EXPANDING FIGURE ON SCREEN
%set(gcf, 'units','points','outerposition',[64.5,1235.25,648.75,581.25]);

hold off
end

