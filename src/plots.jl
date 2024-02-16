using CairoMakie
using NCDatasets


"Show an arrow plot of the surface wind."
function plot_wind(
    ncfilename_u::String,
    ncfilename_v::String;
    time_index::Int=1,
    skip::Int=10,
    fig::Figure=Figure(),
    ax::Axis=Axis(fig[1,1]),
    kwargs...
)
    lat, lon = map(x -> thinner(x, skip)[:], get_latlon())
    tauu = NCDataset(ncfilename_u)["tauuo"][:, :, time_index]
    tauv = NCDataset(ncfilename_v)["tauvo"][:, :, time_index]
    fig = isnothing(fig) ? Figure() : fig
    ax = isnothing(ax) ? Axis(fig[1,1], backgroundcolor="black") : ax
    tauu = min2zero(thinner(tauu, skip)[:])
    tauv = min2zero(thinner(tauv, skip)[:])
    u = sqrt.(tauu / (1.22 * 1.5e-3))
    v = sqrt.(tauv / (1.22 * 1.5e-3))
    speed = sqrt.(u.^2 + v.^2)
    plt = arrows!(ax, lon, lat, u, v; linecolor=speed, arrowcolor=speed, kwargs...)
    Colorbar(fig[1,2], plt, label="Wind speed [m/s]")
    return fig
end


"Show an arrow plot of the surface current."
function plot_surface_current(
    ncfilename_u::String,
    ncfilename_v::String;
    time_index::Int=1,
    skip::Int=10,
    fig=nothing,
    ax=nothing,
    kwargs...
)
    lat, lon = map(x -> thinner(x, skip)[:], get_latlon())
    u = NCDataset(ncfilename_u)["uos"][:, :, time_index]
    v = NCDataset(ncfilename_v)["vos"][:, :, time_index]
    fig = isnothing(fig) ? Figure() : fig
    ax = isnothing(ax) ? Axis(fig[1,1], backgroundcolor="black") : ax
    u = thinner(u, skip)[:]
    v = thinner(v, skip)[:]
    speed = sqrt.(u.^2 + v.^2)
    plt = arrows!(ax, lon, lat, u, v; linecolor=speed, arrowcolor=speed, kwargs...)
    Colorbar(fig[1,2], plt, label="Current [m/s]")
    return fig
end


"Show a surface plot of a field in NetCDF file."
function plot_field(
    filename::String,
    fieldname::String;
    coord_filename::String="",
    km_ticks::Bool=false,
    kwargs...
)
    data = NCDataset(filename)[fieldname]
    isempty(coord_filename) && (coord_filename = filename)
    fig, ax, plt = _surface!(data; coord_filename=coord_filename, kwargs...)
    label = haskey(kwargs, :label) ? kwargs[:label] : fieldname
    Colorbar(fig[1,2], plt, label=label)
    if km_ticks
        lat, lon = get_latlon(coord_filename)
        _set_ticks_in_km!(ax, lat, lon)
    end
    return fig
end


"Animate a field in NetCDF file."
function animate_field(
    filename::String,
    fieldname::String;
    skip::Int=1,
    level::Int=0,
    framerate::Int=5,
    kwargs...
)
    lat, lon = get_latlon()
    mask = get_mask()
    var = NCDataset(filename)[fieldname]
    data = (level > 0) ? var[:, :, level, :] : var[:, :, :]
    obs = Observable(data[:, :, 1] .* mask)
    fig, ax, plt = _surface!(obs, colorrange=extrema(data))
    label = haskey(kwargs, :label) ? kwargs[:label] : fieldname
    Colorbar(fig[1,2], plt, label=label);

    rec = Record(fig, 1:size(data)[3], framerate=framerate) do i
        obs[] = data[:, :, i] .* mask
    end

    return rec
end


function _surface!(
    data::Union{AbstractArray, Observable};
    time_index::Int=1,
    skip::Int=1,
    level::Int=0,
    coord_filename::String=COORD_FILENAME,
    drop_ghosts::Bool=false,
    kwargs...
)
    lat, lon = map(x -> thinner(x, skip), get_latlon(coord_filename))
    if typeof(data) <: AbstractArray
        mask = thinner(get_mask(), skip)
        level > 0 && (data = data[:, :, level, :])
        ndims(data) == 3 && (data = data[:, :, time_index])
        data = (thinner(data, skip) .* mask)
    end
    fig = haskey(kwargs, :fig) ? kwargs[:fig] : begin
        Figure(size=(1000, 1000*size(lat)[2] ÷ size(lat)[1]))
    end
    ax = get(kwargs, :ax, Axis(fig[1,1]))
    plt = surface!(ax, lon, lat, data; kwargs...)
    return fig, ax, plt
end


"Show kilometers on axes instead of degrees."
function _set_ticks_in_km!(
    ax::Axis,
    lat::Matrix{T},
    lon::Matrix{T},
) where T <: Number

    lon = lon[:, 1]
    lat = lat[1, :]
    xticklabs, x_inds = _get_ticks(lon, 8)
    yticklabs, y_inds = _get_ticks(lat, 5)
    ax.xticks = (lon[x_inds], string.(xticklabs))
    ax.yticks = (lat[y_inds], string.(yticklabs))
end


function _get_ticks(
    coords::Vector{T},
    max_labels::Int,
) where T <: Number

    R = 6371.0
    diffs = vcat([coords[2]-coords[1]], diff(coords))
    distance = cumsum(tand.(diffs) * R)
    ticks = []
    for i=3:max_labels
        try
            ticks = collect(Int, range(0, round(maximum(distance)), i))
        catch
            continue
        end
    end
    inds = [1]
    for t in ticks[2:end]
        ind = findfirst(abs.(distance .- t) .< 1e-1)
        push!(inds, ind)
    end
    return ticks, inds
end
