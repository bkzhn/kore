#!/bin/sh
#
# Linux specific defines and system call maps.

if [ -z "$TARGET_PLATFORM" ]; then
	PLATFORM=$(uname -m)
else
	PLATFORM=$TARGET_PLATFORM
fi

BASE=$(dirname $0)

case "$PLATFORM" in
	x86_64*)
		seccomp_audit_arch=AUDIT_ARCH_X86_64
		syscall_file=$BASE/linux/x86_64_syscall.h.in
		;;
	i386)
		seccomp_audit_arch=AUDIT_ARCH_I386
		syscall_file=$BASE/linux/i386_syscall.h.in
		;;
	arm*)
		seccomp_audit_arch=AUDIT_ARCH_ARM
		syscall_file=$BASE/linux/arm_syscall.h.in
		;;
	aarch64*)
		seccomp_audit_arch=AUDIT_ARCH_AARCH64
		syscall_file=$BASE/linux/aarch64_syscall.h.in
		;;
	*)
		>&2 echo "$PLATFORM not supported"
		exit 1
		;;
esac

cat << __EOF
/* Auto generated by linux-platform.sh - DO NOT EDIT */

#include <sys/syscall.h>

#define SECCOMP_AUDIT_ARCH $seccomp_audit_arch

struct {
  const char *name;
  int  nr;
} kore_syscall_map [] = {
__EOF

sed 's/__NR_//' $syscall_file | awk '/#define/ { syscall = $2; number = $3; printf "  { \"%s\", %d },\n", syscall, number }'

cat << __EOF
  { NULL, 0 }
};
__EOF
