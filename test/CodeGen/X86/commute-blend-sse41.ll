; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown -mattr=+sse4.1 | FileCheck %s

define <8 x i16> @commute_fold_pblendw(<8 x i16> %a, <8 x i16>* %b) {
; CHECK-LABEL: commute_fold_pblendw:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0],mem[1,2,3],xmm0[4],mem[5,6,7]
; CHECK-NEXT:    retq
  %1 = load <8 x i16>, <8 x i16>* %b
  %2 = call <8 x i16> @llvm.x86.sse41.pblendw(<8 x i16> %1, <8 x i16> %a, i8 17)
  ret <8 x i16> %2
}
declare <8 x i16> @llvm.x86.sse41.pblendw(<8 x i16>, <8 x i16>, i8) nounwind readnone

define <4 x float> @commute_fold_blendps(<4 x float> %a, <4 x float>* %b) {
; CHECK-LABEL: commute_fold_blendps:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0],mem[1],xmm0[2],mem[3]
; CHECK-NEXT:    retq
  %1 = load <4 x float>, <4 x float>* %b
  %2 = call <4 x float> @llvm.x86.sse41.blendps(<4 x float> %1, <4 x float> %a, i8 5)
  ret <4 x float> %2
}
declare <4 x float> @llvm.x86.sse41.blendps(<4 x float>, <4 x float>, i8) nounwind readnone

define <2 x double> @commute_fold_blendpd(<2 x double> %a, <2 x double>* %b) {
; CHECK-LABEL: commute_fold_blendpd:
; CHECK:       # %bb.0:
; CHECK-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0,1],mem[2,3]
; CHECK-NEXT:    retq
  %1 = load <2 x double>, <2 x double>* %b
  %2 = call <2 x double> @llvm.x86.sse41.blendpd(<2 x double> %1, <2 x double> %a, i8 1)
  ret <2 x double> %2
}
declare <2 x double> @llvm.x86.sse41.blendpd(<2 x double>, <2 x double>, i8) nounwind readnone

define <4 x i32> @commute_fold_blend_v4i32(<4 x i32>* %a, <4 x i32> %b) {
; CHECK-LABEL: commute_fold_blend_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    paddd %xmm0, %xmm0
; CHECK-NEXT:    pblendw {{.*#+}} xmm0 = mem[0,1,2,3,4,5],xmm0[6,7]
; CHECK-NEXT:    retq
  %1 = load <4 x i32>, <4 x i32>* %a
  %2 = add <4 x i32> %b, %b ; force integer domain
  %3 = shufflevector <4 x i32> %1, <4 x i32> %2, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  ret <4 x i32> %3
}
