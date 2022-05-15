BeagleBoard branch:
------------

    git clone https://github.com/beagleboard/image-builder.git

Release Process:

    bb.org-v201Y.MM.DD
    git tag -a bb.org-v201Y.MM.DD -m 'bb.org-v201Y.MM.DD'
    git push origin --tags

Master branch:
------------

    git clone https://github.com/RobertCNelson/omap-image-builder



Release Process:

    vYEAR.MONTH
    git tag -a v202y.mm -m 'v202y.mm'
    git push origin --tags

MachineKit:
------------

    ./riscv64-builder.sh -c machinekit-debian-stretch
    http://elinux.org/Beagleboard:BeagleBoneBlack_Debian#BBW.2FBBB_.28All_Revs.29_Machinekit

