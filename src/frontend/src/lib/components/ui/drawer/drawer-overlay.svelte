<script lang="ts">
  import { Drawer as DrawerPrimitive } from "vaul-svelte";
  import { cn } from "$lib/utils";

  type $$Props = DrawerPrimitive.OverlayProps;

  export let el: $$Props["el"] = undefined;
  let className: $$Props["class"] = undefined;
  let overlayHeight: string = ""; // Default height is empty, can be overridden with a specific class if needed
  export { className as class };
</script>

<DrawerPrimitive.Overlay
  bind:el
  class={cn("fixed inset-0 z-50 bg-black/80", overlayHeight, className)}
  {...$$restProps}
>
  <slot />
</DrawerPrimitive.Overlay>
