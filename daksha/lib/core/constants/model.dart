/// Single source of truth for the Gemma 4 model file we ship and download.
///
/// Referenced from [main.dart] (auto-recovery on launch) and
/// [model_setup_screen.dart] (download + manual install). Keep these aligned
/// or the recovery code will silently register a stale file after an upgrade.
const kModelFilename = 'gemma-4-E4B-it.litertlm';

/// HuggingFace URL for the Gemma 4 E4B instruction-tuned LiteRT-LM model.
///
/// Uses the `/resolve/` redirect endpoint which bounces to HuggingFace's CDN
/// (cdn-lfs-us-1.huggingface.co). dart:io HttpClient follows the redirect
/// automatically and gets a proper Content-Length for progress tracking.
const kModelUrl =
    'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm'
    '/resolve/main/$kModelFilename';

/// Approx download size — used as the progress bar fallback before the server
/// reports `Content-Length`. The full file is ~3.65 GB.
const kModelSizeBytes = 3_921_000_000;

/// Files smaller than this are treated as truncated downloads and deleted on
/// launch. MediaPipe rejects partial files with "Model may be invalid" anyway.
const kModelMinValidBytes = 3_500_000_000;

/// KV-cache budget for [MediaPipeEngine]. The engine allocates this much GPU
/// memory at load time, so smaller is better — but it also caps the entire
/// session window (prefill + decode). The chat path in [SocraticService.judgeOrReply]
/// inlines the running history into every prompt, so the budget has to fit:
/// system preamble + routing instructions (~400 tok) + problem text (~100 tok)
/// + capped history (see [kJudgeReplyHistoryTurns]) + 192 tok output. 1024 leaves
/// headroom for ~6–8 prior turns; bump further if conversations routinely truncate.
const kModelMaxTokens = 1024;

/// Sliding-window cap on prior turns sent to [SocraticService.judgeOrReply].
/// History grows linearly with each exchange; without this cap a long
/// conversation would eventually overflow [kModelMaxTokens] regardless of how
/// generous the budget is. 8 covers ~4 back-and-forth exchanges — enough for
/// the model to interpret short follow-ups in context.
const kJudgeReplyHistoryTurns = 8;
