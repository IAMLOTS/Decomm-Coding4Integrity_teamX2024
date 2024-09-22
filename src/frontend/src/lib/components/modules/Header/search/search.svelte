<script lang="ts">
  import { fade } from "svelte/transition";
  import { browser } from "$app/environment";
  import { createDialog, melt } from "@melt-ui/svelte";
  import SearchIcon from "./search-icon.svelte";
  import { onNavigate } from "$app/navigation";
  import type { Result } from "./search";
  import Card from "$lib/components/modules/app/Card/Card.svelte";
  import { createPostsIndex, searchPostsIndex } from "./search";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { onMount } from "svelte";

  const {
    elements: { trigger, portalled, overlay, content },
    states: { open },
  } = createDialog();
  const platform = browser && window.navigator.platform;

  let search: "idle" | "load" | "ready" = "idle";
  let searchTerm = "";
  let previousSearchTerm = "";
  let results: Result[] = [];
  let timeout: number | undefined;
  let empty = false;
  let isReady = false;

  async function convertBigIntToNumber(products: any[]) {
    return products.map((product) => ({
      ...product,
      productPrice: {
        ...product.productPrice,
        amount: Number(product.productPrice.amount),
      },
      productID: Number(product.productID),
    }));
  }

  onMount(async () => {
    if (search === "ready") return;
    search = "load";
    const resProduct = await actorBackend.getAllProductTypes();
    const converted = await convertBigIntToNumber(resProduct);
    createPostsIndex(converted);
    search = "ready";
    isReady = true;
  });

  onNavigate(() => {
    $open = false;
  });

  function triggerSearch() {
    if (search === "ready") {
      results = searchPostsIndex(searchTerm);
      previousSearchTerm = searchTerm;
      empty = results.length === 0;
    }
  }

  $: if (searchTerm || searchTerm !== previousSearchTerm) {
    if (timeout) {
      clearTimeout(timeout);
    }
    timeout = window.setTimeout(triggerSearch, 1000);
  }

  $: if (searchTerm && !$open) {
    searchTerm = "";
  }
</script>

<svelte:window
  on:keydown={(e) => {
    if (e.ctrlKey || e.metaKey) {
      if (e.key === "k" || e.key === "K") {
        e.preventDefault();
        $open = !$open;
      }
    }
  }}
/>

<button
  use:melt={$trigger}
  class="flex items-center justify-center gap-2 px-4 py-2 border-2 rounded-[20px] font-semibold w-full md:w-[50vh] xl:w-full"
>
  <SearchIcon />
  <span class="hidden sm:block">Search</span>
  <div class="hidden sm:block">
    <kbd
      class="px-2 text-search-kbd-txt bg-search-kbd-bg border border-search-kbd-border rounded"
      >{platform === "MacIntel" ? "⌘" : "Ctrl"}</kbd
    >
    +
    <kbd
      class="px-2 py-1 text-search-kbd-txt bg-search-kbd-bg border border-search-kbd-border rounded"
      >K</kbd
    >
  </div>
</button>

<div use:melt={$portalled}>
  {#if $open}
    <div
      in:fade={{ duration: 200 }}
      use:melt={$overlay}
      class="fixed inset-0 bg-black/80 backdrop-blur-sm z-30"
    />
    <div
      use:melt={$content}
      class="fixed left-1/2 top-5 lg:top-20 w-[90vw] 2xl:w-[80vw] translate-x-[-50%] translate-y-0 rounded-tl-2xl z-40"
    >
      <input
        bind:value={searchTerm}
        placeholder={isReady ? "Search" : "Loading"}
        autocomplete="off"
        spellcheck="false"
        type="search"
        disabled={!isReady}
        class="w-full p-4 text-center text-search-input-txt bg-white focus:outline-none border-zinc-400 border-[3px] rounded-t-xl"
      />
      <div
        class="min-h-[85vh] max-h-[85vh] xl:min-h-[80vh] xl:max-h-[80vh] p-2 bg-white overflow-y-auto scrollbar-thin rounded-b-xl border-zinc-400 border-x-[3px] border-b-[3px]"
        id="searchingBox"
      >
        {#if search === "load"}
          <div
            class="flex text-lg lg:text-3xl justify-center items-center min-h-[70vh] font-medium [word-spacing:-0.1rem] xl:[word-spacing:-0.2rem] animate-pulse-custom"
          >
            <p>Loading..</p>
          </div>
        {/if}
        {#if search === "ready" && searchTerm === ""}
          <div
            class="flex text-lg lg:text-3xl justify-center items-center min-h-[70vh] font-medium [word-spacing:-0.1rem] xl:[word-spacing:-0.2rem]"
          >
            <p>Search to view Products...</p>
          </div>
        {/if}
        {#if results && results.length > 0}
          <div class="grid grid-cols-12 2xl:mt-5 xl:mt-0">
            <div
              class="col-span-12 grid grid-cols-12 justify-center gap-10 p-2 overflow-x-hidden"
            >
              {#each results as result}
                {#if result.productShortDesc.length > 0}
                  <div
                    class="col-span-12 md:col-span-6 lg:col-span-3 w-full h-1/6 border-zinc-300"
                  >
                    <Card
                      name={result.name}
                      productLongDesc={result.productLongDesc}
                      productCategory={result.productCategory}
                      productShortDesc={result.productShortDesc}
                      productID={result.productID}
                      isSold={result.isSold}
                      isVisible={result.isVisible}
                      sellerID={result.sellerID}
                      productPrice={result.productPrice}
                      productPicture={result.productPicture}
                    />
                  </div>
                {/if}
              {/each}
            </div>
          </div>
        {:else if results && empty && timeout}
          <div
            class="flex text-lg lg:text-3xl justify-center items-center min-h-[70vh] font-medium [word-spacing:-0.1rem] xl:[word-spacing:-0.2rem]"
          >
            <p>No results found for {searchTerm}</p>
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>
