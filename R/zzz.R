#' @include utils.R
NULL

#' @importFrom rJava .jpackage
#' @importFrom rjd3jars check_java_version reload_dictionaries
.onLoad <- function(libname, pkgname) {
    # Loading dependencies
    if (!requireNamespace("rjd3jars", quietly = TRUE)) {
        stop("Loading {rjd3jars} failed", call. = FALSE)
    }
    if (!requireNamespace("rjd3toolkit", quietly = TRUE)) {
        stop("Loading {rjd3toolkit} failed", call. = FALSE)
    }

    # Loading Java class
    jar_dir <- file.path(libname, pkgname, "inst", "java")
    jars_inst <- list.files(
        jar_dir,
        pattern = "\\.jar$",
        full.names = TRUE,
        all.files = TRUE
    )
    result <- rJava::.jpackage(
        pkgname,
        lib.loc = libname,
        morePaths = jars_inst
    )

    if (!result) {
        stop("Loading java packages failed")
    }

    # Loading extractors
    has_java <- rjd3jars::check_java_version(silent = TRUE)
    if (has_java) {
        rjd3jars::reload_dictionaries()
    }

    # Loading Proto class
    #  proto.dir <- system.file("proto", package = pkgname)
    #  RProtoBuf::readProtoFiles2(protoPath = proto.dir)
}
