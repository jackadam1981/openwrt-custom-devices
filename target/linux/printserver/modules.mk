# SPDX-License-Identifier: GPL-2.0-only
#
# Kernel modules for printserver target (RT5350 / Hiker X9).
# Same SoC as ramips/rt305x; kernel builds the same .ko from config-6.12.
# Do not redefine KernelPackages already in ramips/modules.mk to avoid
# duplicate symbol (PACKAGE_kmod-*) and recursive dependency in .config-package.in.
# Required kmods are pulled via DEFAULT_PACKAGES / profile in target.mk and profiles/.
