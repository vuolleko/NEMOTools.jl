module NEMOTools

using NCDatasets

include("plots.jl")

export plot_field, plot_surface_current, plot_wind

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
    isfile(coord_filename) || throw("No such file: " * coord_filename)
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
    isfile(mask_filename) || throw("No such file: " * mask_filename)
    mask = NCDataset(mask_filename)["tmaskutil"][:, :, 1]
    return map(i->mapper[i], mask)
end


function divergence2d(fx::Matrix{Real}, fy::Matrix{Real}, x::Matrix{Real}, y::Matrix{Real})
    dfxdx = diff(fx, dims=1) ./ diff(x, dims=1)
    dfydy = diff(fy, dims=2) ./ diff(y, dims=2)
    return get_middle(dfxdx, 2) + get_middle(dfydy, 1)
end


function vorticity2d(fx::Matrix{Real}, fy::Matrix{Real}, x::Matrix{Real}, y::Matrix{Real})
    dfydx = diff(fy, dims=1) ./ diff(x, dims=1)
    dfxdy = diff(fx, dims=2) ./ diff(y, dims=2)
    return get_middle(dfydx, 2) - get_middle(dfxdy, 1)
end


"Find midpoints (2-point averages) of x along d."
function get_middle(x::AbstractArray, d::Integer)
    n = size(x)[d]
    (selectdim(x, d, 1:n-1) + selectdim(x, d, 2:n)) ./ 2.0
end


end  # module