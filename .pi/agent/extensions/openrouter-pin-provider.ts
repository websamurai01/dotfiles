import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// const ALLOW_FALLBACKS = false;
const ALLOW_FALLBACKS = true;

const TIER_SUFFIX = /:(fp8|fp4|mxfp4|flex|nitro|floor)$/;

const PROVIDER_PINS: Record<string, string[]> = {
  "deepseek/deepseek-v4.1-flash-1017:fp8": [
    // "pearl-research/fp8",
    "deepinfra/fp8",
  ],
};

type ChatPayload = { model?: string } & Record<string, unknown>;

export default function (pi: ExtensionAPI) {
  pi.on("before_provider_request", (event) => {
    const payload = event.payload as ChatPayload;
    const model = (payload.model ?? "").replace(TIER_SUFFIX, "");
    const order = PROVIDER_PINS[`${model}:fp8`];

    if (!order) {
      return;
    }

    return {
      ...payload,
      model: `${model}:fp8`,
      provider: { order, allow_fallbacks: ALLOW_FALLBACKS },
    };
  });
}
