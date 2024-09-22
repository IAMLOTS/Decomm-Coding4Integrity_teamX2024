<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import ViewProducts from "$lib/components/modules/admin/ViewProducts/ViewProducts.svelte";
  import AddProduct from "$lib/components/modules/admin/AddProduct/AddProduct.svelte";
  import { fullName } from "$lib/data/stores/stores";

  let chosen = "Add Products";
</script>

<div
  class="grid grid-cols-12 p-4 mt-24 xl:m-20 xl:p-20 xl:border-4 xl:border-zinc-400 xl:border-solid xl:shadow-2xl max-h-fit"
>
  <div class="col-span-12 h-fit grid grid-cols-12 w-full overflow-scroll mt-5">
    <div class="col-span-12">
      <h1 class="text-2xl font-bold">Welcome {$fullName}!</h1>
      <p class="text-lg border-b-2 border-zinc-300 pb-5 mt-2 opacity-75">
        Manage your products and preferences here.
      </p>
    </div>
    <div class="col-span-12 grid grid-cols-12">
      <div class="col-span-12 lg:hidden flex px-2 justify-around mt-5">
        <div>
          <Button
            class="w-full my-1 justify-start hover:underline {chosen ===
            'Add Products'
              ? 'bg-stone-100'
              : ''}"
            variant="ghost"
            on:click={() => (chosen = "Add Products")}>Add Producs</Button
          >
        </div>
        <div>
          <Button
            class="w-full my-1 justify-start hover:underline {chosen ===
            'View Products'
              ? 'bg-stone-100'
              : ''}"
            variant="ghost"
            on:click={() => (chosen = "View Products")}>View Products</Button
          >
        </div>
      </div>
      <div class="hidden lg:col-span-2 lg:block mt-10">
        <div>
          <Button
            class="w-full my-1 justify-start hover:underline {chosen ===
            'Add Products'
              ? 'bg-stone-100'
              : ''}"
            variant="ghost"
            on:click={() => (chosen = "Add Products")}>Add Producs</Button
          >
        </div>
        <div>
          <Button
            class="w-full my-1 justify-start hover:underline {chosen ===
            'View Products'
              ? 'bg-stone-100'
              : ''}"
            variant="ghost"
            on:click={() => (chosen = "View Products")}>View Products</Button
          >
        </div>
      </div>
      <div
        class="col-span-12 lg:col-span-10 mt-10 px-2 h-fit overflow-scroll lg:pl-10"
      >
        {#if chosen === "Add Products"}
          <AddProduct />
        {:else if chosen === "View Products"}
          <ViewProducts />
        {/if}
      </div>
    </div>
  </div>
</div>
