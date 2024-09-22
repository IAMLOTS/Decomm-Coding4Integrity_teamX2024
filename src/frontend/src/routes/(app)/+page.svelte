<script lang="ts">
  import { loggedIn, accountType } from "$lib/data/stores/stores";
  import ProductCards from "$lib/components/modules/app/ProductCards/ProductCards.svelte";
  import { onMount } from "svelte";

  let loaded = false;

  onMount(async () => {
    if ($accountType.value !== "undefined") {
      $accountType.value = "Personal Account";
      loaded = true;
    }
  });
</script>

<main
  class="bg-zinc-50 min-h-screen flex justify-center items-center pb-16 2xl:mb-0 overflow-y-scroll no-scrollbar z-50"
>
  {#if $loggedIn.value !== false}
    {#if loaded == true}
      <ProductCards />
    {/if}
  {/if}
</main>
