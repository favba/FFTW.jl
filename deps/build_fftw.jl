using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libfftw3"], :libfftw3),
    LibraryProduct(prefix, String["libfftw3f"], :libfftw3f),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaMath/FFTWBuilder/releases/download/v3.3.8+1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/FFTW.aarch64-linux-gnu.tar.gz", "4296ad9af20d4441fd809c6aaa3ee5fa36818b7a2eb3372da7d2ead454b4e570"),
    Linux(:aarch64, :musl) => ("$bin_prefix/FFTW.aarch64-linux-musl.tar.gz", "ef6d4e56bd9e405ef2895a857ffbc07cb7abcf450040a2335b83a95f4a431392"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/FFTW.arm-linux-gnueabihf.tar.gz", "8f8c69a6eca468465734e1fd58801519cea0f7a8f9e08bba93e39315758f7a7c"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/FFTW.arm-linux-musleabihf.tar.gz", "48d137fddab6888bdc59893d22728f081578ff0884954f0f6f5df51afff53ece"),
    Linux(:i686, :glibc) => ("$bin_prefix/FFTW.i686-linux-gnu.tar.gz", "76d85d81a81752a0e08bc2eec51a568a6000928a550c37a181b51340452b1b5f"),
    Linux(:i686, :musl) => ("$bin_prefix/FFTW.i686-linux-musl.tar.gz", "5ee42df3aa002e9511c3cc808f728429e4930bb24df8b461dc137bf49aa71b8f"),
    Windows(:i686) => ("$bin_prefix/FFTW.i686-w64-mingw32.tar.gz", "28b96cb5d78c87d16d305a63a838c5027d319c0292f00c925e14f21c744535a8"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/FFTW.powerpc64le-linux-gnu.tar.gz", "53d305eebb3a152df093d637fe8a4d6288a2b7175bf91ab9242dad62e5e0853a"),
    MacOS(:x86_64) => ("$bin_prefix/FFTW.x86_64-apple-darwin14.tar.gz", "7562aed6279ea965435c8a388be1494b9a18f7e00058d0fa260a711bffde1bd5"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/FFTW.x86_64-linux-gnu.tar.gz", "70dcc7ad2697121564d5d91da9f2544b0e68b026779a45063039a39cd5585711"),
    Linux(:x86_64, :musl) => ("$bin_prefix/FFTW.x86_64-linux-musl.tar.gz", "4bf1c1e7489241c38788bc061f2a091fe72605f67e58411b2933313fa0923877"),
    FreeBSD(:x86_64) => ("$bin_prefix/FFTW.x86_64-unknown-freebsd11.1.tar.gz", "ad70aca12821f6df1c67da74fc2f1b4fa009ac14d8570ff1f912876e731185af"),
    Windows(:x86_64) => ("$bin_prefix/FFTW.x86_64-w64-mingw32.tar.gz", "6726bff25faeca8e29dfce8be5b0fb7da0a380faa9fdb5a5a6c98ea76d009b2f"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
