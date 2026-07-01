#' @include utils.R
NULL

.onLoad <- function(libname, pkgname) {
    jars_inst <- file.path(libname, pkgname, "inst", "java") |>
        list.files(pattern = "\\.jar$", full.names = TRUE, all.files = TRUE)
    result <- rJava::.jpackage(
        pkgname,
        lib.loc = libname,
        morePaths = jars_inst
    )

    if (!result) {
        stop("Loading java packages failed", call. = FALSE)
    }

    # Loading extractors
    if (rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version) {
        rjd3toolkit::reload_dictionaries()
    }

    #  proto.dir <- system.file("proto", package = pkgname)
    #  RProtoBuf::readProtoFiles2(protoPath = proto.dir)
}
