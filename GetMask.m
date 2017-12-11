function mask = GetMask(image)
% label the border part of the image
if ndims(image) >=3
    image = rgb2gray(image);
end
image = im2bw(image, 0);
height = size(image, 1);
width = size(image, 2);
mask = ones(size(image));


% from left to right
for x=1: height
    for y=1:width
        if (y==1)
            if (image(x, y) == 0 || isnan(image(x, y))  )
                mask(x,y)=0;
            end
        else
            if (image(x, y) == 0 || isnan(image(x, y)) && image(x, y - 1) == 0 || isnan(image(x, y)))
                mask(x,y)=0;
            end
        end
        if (mask(x,y)~=0)
            break;
        end
    end
end

% from right to left
for x=1: height
    for y=width: -1 : 1
        if (y==width)
            if (image(x, y) == 0 || isnan(image(x, y)) )
                mask(x,y)=0;
            end
        else
            if (image(x, y) == 0 || isnan(image(x, y)) && image(x, y + 1) == 0 || isnan(image(x, y)))
                mask(x,y)=0;
            end
        end
        if (mask(x,y)~=0)
            break;
        end
    end
end

% from top to bottom
for y=1:width
    for x=1: height
        if (x==1)
            if (image(x, y) == 0 || isnan(image(x, y)) )
                mask(x,y)=0;
            end
        else
            if (image(x-1, y) == 0 || isnan(image(x, y)) && image(x, y) == 0 || isnan(image(x, y)))
                mask(x,y)=0;
            end
        end
        if (mask(x,y)~=0)
            break;
        end
    end
end

% from bottom to top
for y=1:width
    for x=height: -1 : 1
        if (x==height)
            if (image(x, y) == 0 || isnan(image(x, y)) )
                mask(x,y)=0;
            end
        else
            if (image(x+1, y) == 0 || isnan(image(x, y)) && image(x, y) == 0 || isnan(image(x, y)))
                mask(x,y)=0;
            end
        end
        if (mask(x,y)~=0)
            break;
        end
    end
end

