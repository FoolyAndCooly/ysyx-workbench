#include <utils.h>
#include <debug.h>
#include <common.h>
#include <memory.h>
#include <getopt.h>
#include <stdio.h>

void init_difftest(char *ref_so_file, long img_size, int port);
void init_regex();

static void welcome() {
  //Log("Trace: %s", MUXDEF(CONFIG_TRACE, ANSI_FMT("ON", ANSI_FG_GREEN), ANSI_FMT("OFF", ANSI_FG_RED)));
  IFDEF(CONFIG_TRACE, Log("If trace is enabled, a log file will be generated "
        "to record the trace. This may lead to a large log file. "
        "If it is not necessary, you can disable it in menuconfig"));
  Log("Build time: %s, %s", __TIME__, __DATE__);
  printf("Welcome to %s-NPC!\n", ANSI_FMT(str(__GUEST_ISA__), ANSI_FG_YELLOW ANSI_BG_RED));
  printf("For help, type \"help\"\n");
  Log("Exercise: Please remove me in the source code and compile NPC again.");
  //assert(0);
}
void sdb_set_batch_mode();

static char *log_file = NULL;
static char *diff_so_file = NULL;
static char *img_file = NULL;
static int difftest_port = 1234;

static long load_img() {
  if (img_file == NULL) {
    Log("No image is given. Use the default build-in image.");
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open '%s'", img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The image is %s, size = %ld", img_file, size);

  fseek(fp, 0, SEEK_SET);
#ifdef SOC
  int ret = fread(flash_guest_to_host(0), size, 1, fp);
#else 
  int ret = fread(guest_to_host(CONFIG_MBASE), size, 1, fp);
#endif
  assert(ret == 1);

  fclose(fp);
  return size;
}

static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"log"      , required_argument, NULL, 'l'},
    {"diff"     , required_argument, NULL, 'd'},
    {"port"     , required_argument, NULL, 'p'},
    {"help"     , no_argument      , NULL, 'h'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bhl:d:p:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'l': log_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

void init_monitor(int argc, char *argv[]) {
  /* Perform some global initialization. */
 
  /* Parse arguments. */
  parse_args(argc, argv);
  
  /* Open the log file. */
  //init_log();

   /* Load the image to memory. This will overwrite the built-in image. */
  long img_size = load_img();

  /* Initialize differential testing. */
  if (diff_so_file) init_difftest(diff_so_file, img_size, difftest_port);
  init_regex();
}
