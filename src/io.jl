using DataStructures
using NCDatasets


"Create a coordinate file from a domain_cfg file."
function dom2coord(domain_filename::String, coord_filename::String)

    ds0 = NCDataset(domain_filename)
    isfile(coord_filename) && throw("File exists: " * coord_filename)
    ds = NCDataset(coord_filename, "c")

    try

        # Dimensions

        nx, ny = size(ds0["glamu"])
        ds.dim["x"] = nx
        ds.dim["y"] = ny

        # Declare variables

        nce2f = defVar(ds, "e2f", Float64, ("x", "y"))
        nce2v = defVar(ds, "e2v", Float64, ("x", "y"))
        nce2u = defVar(ds, "e2u", Float64, ("x", "y"))
        nce2t = defVar(ds, "e2t", Float64, ("x", "y"))
        nce1f = defVar(ds, "e1f", Float64, ("x", "y"))
        nce1v = defVar(ds, "e1v", Float64, ("x", "y"))
        nce1u = defVar(ds, "e1u", Float64, ("x", "y"))
        nce1t = defVar(ds, "e1t", Float64, ("x", "y"))
        ncgphif = defVar(ds, "gphif", Float64, ("x", "y"))
        ncgphiv = defVar(ds, "gphiv", Float64, ("x", "y"))
        ncgphiu = defVar(ds, "gphiu", Float64, ("x", "y"))
        ncgphit = defVar(ds, "gphit", Float64, ("x", "y"))
        ncglamf = defVar(ds, "glamf", Float64, ("x", "y"))
        ncglamv = defVar(ds, "glamv", Float64, ("x", "y"))
        ncglamu = defVar(ds, "glamu", Float64, ("x", "y"))
        ncglamt = defVar(ds, "glamt", Float64, ("x", "y"))

        # Define variables

        nce2f[:, :] = ds0["e2f"][:, :]
        nce2u[:, :] = ds0["e2u"][:, :]
        nce2t[:, :] = ds0["e2t"][:, :]
        nce2v[:, :] = ds0["e2v"][:, :]
        nce1f[:, :] = ds0["e1f"][:, :]
        nce1v[:, :] = ds0["e1v"][:, :]
        nce1u[:, :] = ds0["e1u"][:, :]
        nce1t[:, :] = ds0["e1t"][:, :]
        ncglamt[:, :] = ds0["glamt"][:, :]
        ncglamf[:, :] = ds0["glamf"][:, :]
        ncglamv[:, :] = ds0["glamv"][:, :]
        ncglamu[:, :] = ds0["glamu"][:, :]
        ncgphit[:, :] = ds0["gphit"][:, :]
        ncgphif[:, :] = ds0["gphif"][:, :]
        ncgphiv[:, :] = ds0["gphiv"][:, :]
        ncgphiu[:, :] = ds0["gphiu"][:, :]
        
    finally
        close(ds0)
        close(ds)
    end
    return
end
