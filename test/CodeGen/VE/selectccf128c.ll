; RUN: llc < %s -mtriple=ve-unknown-unknown | FileCheck %s

define fp128 @selectccsgti8(i8, i8, fp128, fp128) {
; CHECK-LABEL: selectccsgti8:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    sla.w.sx %s34, %s1, 24
; CHECK-NEXT:    sra.w.sx %s34, %s34, 24
; CHECK-NEXT:    sla.w.sx %s35, %s0, 24
; CHECK-NEXT:    sra.w.sx %s35, %s35, 24
; CHECK-NEXT:    cmps.w.sx %s34, %s35, %s34
; CHECK-NEXT:    cmov.w.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.w.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = icmp sgt i8 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccsgti16(i16, i16, fp128, fp128) {
; CHECK-LABEL: selectccsgti16:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    sla.w.sx %s34, %s1, 16
; CHECK-NEXT:    sra.w.sx %s34, %s34, 16
; CHECK-NEXT:    sla.w.sx %s35, %s0, 16
; CHECK-NEXT:    sra.w.sx %s35, %s35, 16
; CHECK-NEXT:    cmps.w.sx %s34, %s35, %s34
; CHECK-NEXT:    cmov.w.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.w.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = icmp sgt i16 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccsgti32(i32, i32, fp128, fp128) {
; CHECK-LABEL: selectccsgti32:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    cmps.w.sx %s34, %s0, %s1
; CHECK-NEXT:    cmov.w.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.w.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = icmp sgt i32 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccsgti64(i64, i64, fp128, fp128) {
; CHECK-LABEL: selectccsgti64:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    cmps.l %s34, %s0, %s1
; CHECK-NEXT:    cmov.l.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.l.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = icmp sgt i64 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccsgti128(i128, i128, fp128, fp128) {
; CHECK-LABEL: selectccsgti128:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    or %s34, 0, (0)1
; CHECK-NEXT:    cmps.l %s35, %s1, %s3
; CHECK-NEXT:    or %s36, 0, %s34
; CHECK-NEXT:    cmov.l.gt %s36, (63)0, %s35
; CHECK-NEXT:    cmpu.l %s37, %s0, %s2
; CHECK-NEXT:    cmov.l.gt %s34, (63)0, %s37
; CHECK-NEXT:    cmov.l.eq %s36, %s34, %s35
; CHECK-NEXT:    or %s34, 0, (0)1
; CHECK-NEXT:    cmps.w.sx %s34, %s36, %s34
; CHECK-NEXT:    cmov.w.ne %s6, %s4, %s34
; CHECK-NEXT:    cmov.w.ne %s7, %s5, %s34
; CHECK-NEXT:    or %s0, 0, %s6
; CHECK-NEXT:    or %s1, 0, %s7
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = icmp sgt i128 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccogtf32(float, float, fp128, fp128) {
; CHECK-LABEL: selectccogtf32:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    fcmp.s %s34, %s0, %s1
; CHECK-NEXT:    cmov.s.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.s.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = fcmp ogt float %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccogtf64(double, double, fp128, fp128) {
; CHECK-LABEL: selectccogtf64:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    fcmp.d %s34, %s0, %s1
; CHECK-NEXT:    cmov.d.gt %s4, %s2, %s34
; CHECK-NEXT:    cmov.d.gt %s5, %s3, %s34
; CHECK-NEXT:    or %s0, 0, %s4
; CHECK-NEXT:    or %s1, 0, %s5
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = fcmp ogt double %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

define fp128 @selectccogtf128(fp128, fp128, fp128, fp128) {
; CHECK-LABEL: selectccogtf128:
; CHECK:       .LBB{{[0-9]+}}_2:
; CHECK-NEXT:    fcmp.q %s34, %s0, %s2
; CHECK-NEXT:    cmov.d.gt %s6, %s4, %s34
; CHECK-NEXT:    cmov.d.gt %s7, %s5, %s34
; CHECK-NEXT:    or %s0, 0, %s6
; CHECK-NEXT:    or %s1, 0, %s7
; CHECK-NEXT:    or %s11, 0, %s9
  %5 = fcmp ogt fp128 %0, %1
  %6 = select i1 %5, fp128 %2, fp128 %3
  ret fp128 %6
}

