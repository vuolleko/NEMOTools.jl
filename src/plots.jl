using CairoMakie, NCDatasets


function plot_wind(ncfilename::String; time_index::Int=1, skip::Int=10)
    lat, lon = map(x -> thinner(x, skip)[:], get_latlon())
    tauu = NCDataset(ncfilename)["tauuo"][:, :, time_index]
    tauv = NCDataset(ncfilename)["tauvo"][:, :, time_index]
    fig = Figure(resolution=size(tauu))
    tauu = min2zero(thinner(tauu, skip)[:])
    tauv = min2zero(thinner(tauv, skip)[:])
    u = sqrt.(tauu / (1.22 * 1.5e-3))
    v = sqrt.(tauv / (1.22 * 1.5e-3))
    speed = sqrt.(u.^2 + v.^2)
    ax = Axis(fig[1, 1], backgroundcolor="black")
    arrows!(ax, lon, lat, u, v, linecolor=speed, arrowcolor=speed, arrowsize = 10, lengthscale = 1e-4, linewidth=2)
    return fig
end


function plot_surface_current(ncfilename_u::String, ncfilename_v::String; time_index::Int=1, skip::Int=10)
    lat, lon = map(x -> thinner(x, skip)[:], get_latlon())
    u = NCDataset(ncfilename_u)["uos"][:, :, time_index]
    v = NCDataset(ncfilename_v)["vos"][:, :, time_index]
    fig = Figure(resolution=size(u))
    u = thinner(u, skip)[:]
    v = thinner(v, skip)[:]
    speed = sqrt.(u.^2 + v.^2)
    ax = Axis(fig[1, 1], backgroundcolor="black")
    arrows!(ax, lon, lat, u, v, linecolor=speed, arrowcolor=speed, arrowsize = 5, lengthscale = 1e-2, linewidth=2)
    return fig
end


function plot_field(filename::String, fieldname::String; time_index::Int=1, skip::Int=1, level::Int=0, 
    fig=nothing, ax=nothing, kwargs...)
    lat, lon = map(x -> thinner(x, skip)[:], get_latlon())
    mask = thinner(get_mask(), skip)
    if (level > 0)
    data = NCDataset(filename)[fieldname][:, :, level, time_index]
    else
    data = NCDataset(filename)[fieldname][:, :, time_index]
    end
    data1 = (thinner(data, skip) .* mask)[:]
    fig = isnothing(fig) ? Figure(resolution=size(data)) : fig
    ax = isnothing(ax) ? Axis(fig[1,1]) : ax
    plt = surface!(ax, lon, lat, data1)
    label = haskey(kwargs, :label) ? kwargs[:label] : fieldname
    Colorbar(fig[1,2], plt, label=label)
    return fig
end


function animate_field(filename::String, fieldname::String; skip::Int=1, level::Int=0, 
    fig=nothing, ax=nothing, framerate::Int=5, kwargs...)
    lat, lon = get_latlon()
    mask = get_mask()
    data = NCDataset(filename)[fieldname][:]
    level > 0 && (data = data[:, :, level, :])
    data1 = Observable(data[:, :, 1] .* mask)
    fig = isnothing(fig) ? Figure(resolution=size(data[:, :, 1]) .* 1.5) : fig
    ax = isnothing(ax) ? Axis(fig[1,1]) : ax
    plt = surface!(ax, lon, lat, data1, colorrange=extrema(data))
    label = haskey(kwargs, :label) ? kwargs[:label] : fieldname
    Colorbar(fig[1,2], plt, label=label);

    rec = Record(fig, 1:size(data)[3], framerate=framerate) do i
        data1[] = data[:, :, i] .* mask
    end
    
    return rec
end