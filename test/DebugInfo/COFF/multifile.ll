; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -O0 < %s | FileCheck --check-prefix=X86 %s
; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -o - -O0 < %s | llvm-mc -triple=i686-pc-win32 -filetype=obj | llvm-readobj -s -sr -codeview -section-symbols | FileCheck --check-prefix=OBJ32 %s
; RUN: llc -mcpu=core2 -mtriple=x86_64-pc-win32 -O0 < %s | FileCheck --check-prefix=X64 %s
; RUN: llc -mcpu=core2 -mtriple=x86_64-pc-win32 -o - -O0 < %s | llvm-mc -triple=x86_64-pc-win32 -filetype=obj | llvm-readobj -s -sr -codeview -section-symbols | FileCheck --check-prefix=OBJ64 %s

; This LL file was generated by running clang on the following code:
; D:\input.c:
;  1 void g(void);
;  2
;  3 void f(void) {
;  4 #line 1 "one.c"
;  5   g();
;  6 #line 2 "two.c"
;  7   g();
;  8 #line 7 "one.c"
;  9   g();
; 10 }

; X86-LABEL: _f:
; X86:      # %bb.
; X86:      .cv_file 1 "D:\\one.c" "70B51F534D80639D033AE92C6A856AF6" 1
; X86:      .cv_loc 0 1 1 0 # one.c:1:0
; X86:      calll   _g
; X86:      .cv_file 2 "D:\\two.c" "70B51F534D80639D033AE92C6A856AF6" 1
; X86:      .cv_loc 0 2 2 0 # two.c:2:0
; X86:      calll   _g
; X86:      .cv_loc 0 1 7 0 # one.c:7:0
; X86:      calll   _g
; X86:      .cv_loc 0 1 8 0 # one.c:8:0
; X86:      ret
; X86:      [[END_OF_F:.?Lfunc_end.*]]:

; Line table
; X86:      .cv_linetable 0, _f, [[END_OF_F]]
; File index to string table offset subsection
; X86-NEXT: .cv_filechecksums
; String table
; X86-NEXT: .cv_stringtable

; OBJ32:    Section {
; OBJ32:      Name: .debug$S (2E 64 65 62 75 67 24 53)
; OBJ32:      Characteristics [ (0x42300040)
; OBJ32:      ]
; OBJ32:      Subsection [
; OBJ32-NEXT:   SubSectionType: Symbols (0xF1)
; OBJ32:        {{.*}}Proc{{.*}}Sym {
; OBJ32:          CodeSize: 0x10
; OBJ32:          DisplayName: f
; OBJ32:          LinkageName: _f
; OBJ32:        }
; OBJ32:        ProcEnd {
; OBJ32:        }
; OBJ32-NEXT: ]
; OBJ32:	  Subsection [
; OBJ32:        SubSectionType: FileChecksums (0xF4)
; OBJ32-NEXT:   SubSectionSize: 0x30
; OBJ32-NEXT:   FileChecksum {
; OBJ32-NEXT:     Filename: D:\one.c (0x1)
; OBJ32-NEXT:     ChecksumSize: 0x10
; OBJ32-NEXT:     ChecksumKind: MD5 (0x1)
; OBJ32-NEXT:     ChecksumBytes: (70 B5 1F 53 4D 80 63 9D 03 3A E9 2C 6A 85 6A F6)
; OBJ32-NEXT:   }
; OBJ32-NEXT:   FileChecksum {
; OBJ32-NEXT:     Filename: D:\two.c (0xA)
; OBJ32-NEXT:     ChecksumSize: 0x10
; OBJ32-NEXT:     ChecksumKind: MD5 (0x1)
; OBJ32-NEXT:     ChecksumBytes: (70 B5 1F 53 4D 80 63 9D 03 3A E9 2C 6A 85 6A F6)
; OBJ32-NEXT:   }
; OBJ32-NEXT:  ]
; OBJ32:      FunctionLineTable [
; OBJ32-NEXT:   Name: _f
; OBJ32-NEXT:   Flags: 0x0
; OBJ32-NEXT:   CodeSize: 0x10
; OBJ32-NEXT:   FilenameSegment [
; OBJ32-NEXT:     Filename: D:\one.c
; OBJ32-NEXT:     +0x0 [
; OBJ32-NEXT:       LineNumberStart: 1
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: No
; OBJ32-NEXT:     ]
; OBJ32-NEXT:   ]
; OBJ32-NEXT:   FilenameSegment [
; OBJ32-NEXT:     Filename: D:\two.c
; OBJ32-NEXT:     +0x5 [
; OBJ32-NEXT:       LineNumberStart: 2
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: No
; OBJ32-NEXT:     ]
; OBJ32-NEXT:   ]
; OBJ32-NEXT:   FilenameSegment [
; OBJ32-NEXT:     Filename: D:\one.c
; OBJ32-NEXT:     +0xA [
; OBJ32-NEXT:       LineNumberStart: 7
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: No
; OBJ32-NEXT:     ]
; OBJ32-NEXT:     +0xF [
; OBJ32-NEXT:       LineNumberStart: 8
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: No
; OBJ32-NEXT:     ]
; OBJ32-NEXT:   ]
; OBJ32-NEXT: ]

; X64-LABEL: f:
; X64-NEXT: .L{{.*}}:{{$}}
; X64:      .cv_file 1 "D:\\input.c" "70B51F534D80639D033AE92C6A856AF6" 1
; X64:      .cv_loc 0 1 3 0 # input.c:3:0
; X64:      # %bb.
; X64:      subq    $40, %rsp
; X64:      .cv_file 2 "D:\\one.c" "70B51F534D80639D033AE92C6A856AF6" 1
; X64:      .cv_loc 0 2 1 0 # one.c:1:0
; X64:      callq   g
; X64:      .cv_file 3 "D:\\two.c" "70B51F534D80639D033AE92C6A856AF6" 1
; X64:      .cv_loc 0 3 2 0 # two.c:2:0
; X64:      callq   g
; X64:      .cv_loc 0 2 7 0 # one.c:7:0
; X64:      callq   g
; X64:      .cv_loc 0 2 8 0 # one.c:8:0
; X64:      addq    $40, %rsp
; X64-NEXT: ret
; X64:      [[END_OF_F:.?Lfunc_end.*]]:

; X64: .cv_linetable 0, f, [[END_OF_F]]
; X64: .cv_filechecksums
; X64: .cv_stringtable

; OBJ64:    Section {
; OBJ64:      Name: .debug$S (2E 64 65 62 75 67 24 53)
; OBJ64:      Characteristics [ (0x42300040)
; OBJ64:      ]
; OBJ64:      Subsection [
; OBJ64-NEXT:   SubSectionType: Symbols (0xF1)
; OBJ64:        {{.*}}Proc{{.*}}Sym {
; OBJ64:          CodeSize: 0x18
; OBJ64:          DisplayName: f
; OBJ64:          LinkageName: f
; OBJ64:        }
; OBJ64:        ProcEnd {
; OBJ64:        }
; OBJ64-NEXT: ]
; OBJ64:	  Subsection [
; OBJ64:        SubSectionType: FileChecksums (0xF4)
; OBJ64-NEXT:   SubSectionSize: 0x48
; OBJ64-NEXT:   FileChecksum {
; OBJ64-NEXT:     Filename: D:\input.c (0x1)
; OBJ64-NEXT:     ChecksumSize: 0x10
; OBJ64-NEXT:     ChecksumKind: MD5 (0x1)
; OBJ64-NEXT:     ChecksumBytes: (70 B5 1F 53 4D 80 63 9D 03 3A E9 2C 6A 85 6A F6)
; OBJ64-NEXT:   }
; OBJ64-NEXT:   FileChecksum {
; OBJ64-NEXT:     Filename: D:\one.c (0xC)
; OBJ64-NEXT:     ChecksumSize: 0x10
; OBJ64-NEXT:     ChecksumKind: MD5 (0x1)
; OBJ64-NEXT:     ChecksumBytes: (70 B5 1F 53 4D 80 63 9D 03 3A E9 2C 6A 85 6A F6)
; OBJ64-NEXT:   }
; OBJ64-NEXT:   FileChecksum {
; OBJ64-NEXT:     Filename: D:\two.c (0x15)
; OBJ64-NEXT:     ChecksumSize: 0x10
; OBJ64-NEXT:     ChecksumKind: MD5 (0x1)
; OBJ64-NEXT:     ChecksumBytes: (70 B5 1F 53 4D 80 63 9D 03 3A E9 2C 6A 85 6A F6)
; OBJ64-NEXT:   }
; OBJ64-NEXT:  ]
; OBJ64:      FunctionLineTable [
; OBJ64-NEXT:   Name: f
; OBJ64-NEXT:   Flags: 0x0
; OBJ64-NEXT:   CodeSize: 0x18
; OBJ64-NEXT:   FilenameSegment [
; OBJ64-NEXT:     Filename: D:\input.c
; OBJ64-NEXT:     +0x0 [
; OBJ64-NEXT:       LineNumberStart: 3
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: No
; OBJ64-NEXT:     ]
; OBJ64-NEXT:   ]
; OBJ64-NEXT:   FilenameSegment [
; OBJ64-NEXT:     Filename: D:\one.c
; OBJ64-NEXT:     +0x4 [
; OBJ64-NEXT:       LineNumberStart: 1
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: No
; OBJ64-NEXT:     ]
; OBJ64-NEXT:   ]
; OBJ64-NEXT:   FilenameSegment [
; OBJ64-NEXT:     Filename: D:\two.c
; OBJ64-NEXT:     +0x9 [
; OBJ64-NEXT:       LineNumberStart: 2
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: No
; OBJ64-NEXT:     ]
; OBJ64-NEXT:   ]
; OBJ64-NEXT:   FilenameSegment [
; OBJ64-NEXT:     Filename: D:\one.c
; OBJ64-NEXT:     +0xE [
; OBJ64-NEXT:       LineNumberStart: 7
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: No
; OBJ64-NEXT:     ]
; OBJ64-NEXT:     +0x13 [
; OBJ64-NEXT:       LineNumberStart: 8
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: No
; OBJ64-NEXT:     ]
; OBJ64-NEXT:   ]
; OBJ64-NEXT: ]

; Function Attrs: nounwind
define void @f() #0 !dbg !4 {
entry:
  call void @g(), !dbg !12
  call void @g(), !dbg !15
  call void @g(), !dbg !18
  ret void, !dbg !19
}

declare void @g() #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !10}
!llvm.ident = !{!11}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.5 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "<unknown>", directory: "D:\5C", checksumkind: CSK_MD5, checksum:"70b51f534d80639d033ae92c6a856af6")
!2 = !{}
!4 = distinct !DISubprogram(name: "f", line: 3, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 3, file: !5, scope: !6, type: !7, retainedNodes: !2)
!5 = !DIFile(filename: "input.c", directory: "D:\5C", checksumkind: CSK_MD5, checksum:"70b51f534d80639d033ae92c6a856af6")
!6 = !DIFile(filename: "input.c", directory: "D:C", checksumkind: CSK_MD5, checksum:"70b51f534d80639d033ae92c6a856af6")
!7 = !DISubroutineType(types: !8)
!8 = !{null}
!9 = !{i32 2, !"CodeView", i32 1}
!10 = !{i32 1, !"Debug Info Version", i32 3}
!11 = !{!"clang version 3.5 "}
!12 = !DILocation(line: 1, scope: !13)
!13 = !DILexicalBlockFile(discriminator: 0, file: !14, scope: !4)
!14 = !DIFile(filename: "one.c", directory: "D:\5C", checksumkind: CSK_MD5, checksum:"70b51f534d80639d033ae92c6a856af6")
!15 = !DILocation(line: 2, scope: !16)
!16 = !DILexicalBlockFile(discriminator: 0, file: !17, scope: !4)
!17 = !DIFile(filename: "two.c", directory: "D:\5C", checksumkind: CSK_MD5, checksum:"70b51f534d80639d033ae92c6a856af6")
!18 = !DILocation(line: 7, scope: !13)
!19 = !DILocation(line: 8, scope: !13)
