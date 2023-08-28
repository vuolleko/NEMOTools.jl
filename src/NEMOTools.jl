module NEMOTools

using NCDatasets

include("plots.jl")

const coord_filename::String="domain_cfg.nc"
const mask_filename::String="mesh_mask.nc"


function thinner(A::AbstractArray, skip::Int=10)
    lens = size(A)
    B = copy(A)
    for i in 1:length(lens)
        B = selectdim(B, i, 1:skip:lens[i])
    end
    return typeof(A)(B)
end


function get_latlon(coord_filename::String=coord_filename)
    isfile(coord_filename) || throw("No such file")
    lat = NCDataset(coord_filename)["nav_lat"][:]
    lon = NCDataset(coord_filename)["nav_lon"][:]
    return lat, lon
end


function min2zero(arr::AbstractArray)
    arr = copy(arr)
    inds = findall(x -> x<0, arr)
    arr[inds] .= 0
    return arr
end


function get_mask(mapper=Dict([(0, NaN), (1, 1)]), mask_filename::String=mask_filename)
    isfile(mask_filename) || throw("No such file")
    mask = NCDataset(mask_filename)["tmaskutil"][:, :, 1]
    return map(i->mapper[i], mask)
end


function divergence2d(fx, fy, x, y)
    dfxdx = (diff(fx, dims=1) ./ diff(x, dims=1))[:, 1:end-1]
    dfydy = (diff(fy, dims=2) ./ diff(y, dims=2))[2:end, :]
    return dfxdx + dfydy
end

function vorticity2d(fx, fy, x, y)
    dfydx = (diff(fy, dims=1) ./ diff(x, dims=1))[:, 1:end-1]
    dfxdy = (diff(fx, dims=2) ./ diff(y, dims=2))[2:end, :]    
    return dfydx - dfxdy
end


end
