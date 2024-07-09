#include "frida-gumjs.h"

#include "instrument.h"
#include "persistent.h"
#include "util.h"

#if defined(__arm__)

// struct _GumArmCpuContext {

//   guint32 pc;
//   guint32 sp;
//   guint32 cpsr;

//   guint32 r8;
//   guint32 r9;
//   guint32 r10;
//   guint32 r11;
//   guint32 r12;

//   GumArmVectorReg v[16];

//   guint32 _padding;

//   guint32 r[8];
//   guint32 lr;
// };

// r11 - fp
// r12 - ip
// r13 - sp
// r14 - lr
// r15 - pc

static GumCpuContext saved_regs = {0};
static gpointer      saved_lr = NULL;

gboolean persistent_is_supported(void) {

  return true;

}

static void instrument_persitent_save_regs(GumArmWriter  *cw,
                                           GumCpuContext *regs) {

  /* Save Regs */
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R0, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE);
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE + sizeof(guint32));

  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R0, GUM_ADDRESS(regs));

  /* Save r1-r7 */
  for (size_t i = ARM_REG_R1; i < ARM_REG_R8; i++) {

    gum_arm_writer_put_str_reg_reg_offset(
        cw, i, ARM_REG_R0, offsetof(GumCpuContext, r[i - ARM_REG_R0]));

  }

  /* Save r8-r12 */
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R8, ARM_REG_R0,
                                        offsetof(GumCpuContext, r8));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R9, ARM_REG_R0,
                                        offsetof(GumCpuContext, r9));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R10, ARM_REG_R0,
                                        offsetof(GumCpuContext, r10));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R11, ARM_REG_R0,
                                        offsetof(GumCpuContext, r11));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R12, ARM_REG_R0,
                                        offsetof(GumCpuContext, r12));

  /* Save sp & lr */
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_SP, ARM_REG_R0,
                                        offsetof(GumCpuContext, sp));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_LR, ARM_REG_R0,
                                        offsetof(GumCpuContext, lr));

  /* Save r0 (load from stack into r1) */
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE);
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_R0,
                                        offsetof(GumCpuContext, r[0]));

  /* Save CPSR */
  gum_arm_writer_put_mov_reg_cpsr(cw, ARM_REG_R1);
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_R0,
                                        offsetof(GumCpuContext, cpsr));

  /* Save PC */
  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R1,
                                     GUM_ADDRESS(persistent_start));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_R0,
                                        offsetof(GumCpuContext, pc));

  /* Restore Regs */
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE + sizeof(guint32));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R0, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE);

}

static void instrument_persitent_restore_regs(GumArmWriter  *cw,
                                              GumCpuContext *regs) {

  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R0, GUM_ADDRESS(regs));

  /* Restore CPSR */
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_R0,
                                        offsetof(GumCpuContext, cpsr));
  gum_arm_writer_put_mov_cpsr_reg(cw, ARM_REG_R1);

  /* Restore sp & lr */
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_SP, ARM_REG_R0,
                                        offsetof(GumCpuContext, sp));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_LR, ARM_REG_R0,
                                        offsetof(GumCpuContext, lr));

  /* Restore r8-r12 */
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R8, ARM_REG_R0,
                                        offsetof(GumCpuContext, r8));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R9, ARM_REG_R0,
                                        offsetof(GumCpuContext, r9));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R10, ARM_REG_R0,
                                        offsetof(GumCpuContext, r10));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R11, ARM_REG_R0,
                                        offsetof(GumCpuContext, r11));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R12, ARM_REG_R0,
                                        offsetof(GumCpuContext, r12));

  /* Restore r7-r0 */
  for (size_t i = ARM_REG_R7; i >= ARM_REG_R0; i--) {

    gum_arm_writer_put_ldr_reg_reg_offset(
        cw, i, ARM_REG_R0, offsetof(GumCpuContext, r[i - ARM_REG_R0]));

  }

}

static void instrument_exit(GumArmWriter *cw) {

  gum_arm_writer_put_sub_reg_reg_reg(cw, ARM_REG_R0, ARM_REG_R0, ARM_REG_R0);
  gum_arm_writer_put_call_address_with_arguments(cw, GUM_ADDRESS(_exit), 1,
                                                 GUM_ARG_REGISTER, ARM_REG_R0);

}

static int instrument_afl_persistent_loop_func(void) {

  int ret = __afl_persistent_loop(persistent_count);
  if (instrument_previous_pc_addr == NULL) {

    FATAL("instrument_previous_pc_addr uninitialized");

  }

  *instrument_previous_pc_addr = instrument_hash_zero;
  return ret;

}

static void instrument_afl_persistent_loop(GumArmWriter *cw) {

  gum_arm_writer_put_sub_reg_reg_imm(cw, ARM_REG_SP, ARM_REG_SP,
                                     GUM_RED_ZONE_SIZE);
  gum_arm_writer_put_call_address_with_arguments(
      cw, GUM_ADDRESS(instrument_afl_persistent_loop_func), 0);
  gum_arm_writer_put_add_reg_reg_imm(cw, ARM_REG_SP, ARM_REG_SP,
                                     GUM_RED_ZONE_SIZE);

}

static void persistent_prologue_hook(GumArmWriter *cw, GumCpuContext *regs) {

  if (persistent_hook == NULL) return;

  gum_arm_writer_put_sub_reg_reg_imm(cw, ARM_REG_SP, ARM_REG_SP,
                                     GUM_RED_ZONE_SIZE);
  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R2,
                                     GUM_ADDRESS(&__afl_fuzz_len));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R2, ARM_REG_R2, 0);
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R2, ARM_REG_R2, 0);

  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R1,
                                     GUM_ADDRESS(&__afl_fuzz_ptr));
  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R1, ARM_REG_R1, 0);

  gum_arm_writer_put_call_address_with_arguments(
      cw, GUM_ADDRESS(persistent_hook), 3, GUM_ARG_ADDRESS, GUM_ADDRESS(regs),
      GUM_ARG_REGISTER, ARM_REG_R1, GUM_ARG_REGISTER, ARM_REG_R2);

  gum_arm_writer_put_add_reg_reg_imm(cw, ARM_REG_SP, ARM_REG_SP,
                                     GUM_RED_ZONE_SIZE);

}

static void instrument_persitent_save_lr(GumArmWriter *cw) {

  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_R0, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE);

  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R0, GUM_ADDRESS(&saved_lr));
  gum_arm_writer_put_str_reg_reg_offset(cw, ARM_REG_LR, ARM_REG_R0, 0);

  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R0, ARM_REG_SP,
                                        GUM_RED_ZONE_SIZE);

}

void persistent_prologue_arch(GumStalkerOutput *output) {

  /*
   *  SAVE REGS
   *  SAVE RET
   *  POP RET
   * loop:
   *  CALL instrument_afl_persistent_loop
   *  TEST EAX, EAX
   *  JZ end:
   *  call hook (optionally)
   *  RESTORE REGS
   *  call original
   *  jmp loop:
   *
   * end:
   *  JMP SAVED RET
   *
   * original:
   *  INSTRUMENTED PERSISTENT FUNC
   */

  GumArmWriter *cw = output->writer.arm;

  gconstpointer loop = cw->code + 1;

  FVERBOSE("Persistent loop reached");

  instrument_persitent_save_regs(cw, &saved_regs);

  /* loop: */
  gum_arm_writer_put_label(cw, loop);

  /* call instrument_prologue_func */
  instrument_afl_persistent_loop(cw);

  /* jz done */
  gconstpointer done = cw->code + 1;
  gum_arm_writer_put_cmp_reg_imm(cw, ARM_REG_R0, 0);
  gum_arm_writer_put_b_cond_label(cw, ARM_CC_EQ, done);

  /* Optionally call the persistent hook */
  persistent_prologue_hook(cw, &saved_regs);

  instrument_persitent_restore_regs(cw, &saved_regs);
  gconstpointer original = cw->code + 1;
  /* call original */

  gum_arm_writer_put_bl_label(cw, original);

  /* jmp loop */
  gum_arm_writer_put_b_label(cw, loop);

  /* done: */
  gum_arm_writer_put_label(cw, done);

  instrument_exit(cw);

  /* original: */
  gum_arm_writer_put_label(cw, original);

  instrument_persitent_save_lr(cw);

  if (persistent_debug) { gum_arm_writer_put_breakpoint(cw); }

}

void persistent_epilogue_arch(GumStalkerOutput *output) {

  GumArmWriter *cw = output->writer.arm;

  if (persistent_debug) { gum_arm_writer_put_breakpoint(cw); }

  gum_arm_writer_put_ldr_reg_address(cw, ARM_REG_R0, GUM_ADDRESS(&saved_lr));

  gum_arm_writer_put_ldr_reg_reg_offset(cw, ARM_REG_R0, ARM_REG_R0, 0);

  gum_arm_writer_put_bx_reg(cw, ARM_REG_R0);

}

#endif

