<script lang="ts">
  import { Button } from "$lib/components/ui/button";
  import * as Carousel from "$lib/components/ui/carousel";
  import * as Drawer from "$lib/components/ui/drawer";
  import { toast } from "svelte-sonner";
  import { fullName, cart } from "$lib/data/stores/stores";
  import Reload from "svelte-radix/Reload.svelte";
  import { actorBackend } from "$lib/motokoImports/backend";

  const Currency: any = {
    btc: { btc: null },
    eth: { eth: null },
    icp: { icp: null },
    usd: { usd: null },
    eur: { eur: null },
    gbp: { gbp: null },
    kt: { kt: null },
  };

  export type productPrice = {
    currency: typeof Currency;
    amount: number;
  };

  export let productLongDesc: string;
  export let productCategory: string;
  export let name: string;
  export let productShortDesc: string;
  export let productID: number;
  export let isSold: boolean;
  export let isVisible: boolean;
  export let sellerID: string;
  export let productPrice: productPrice;
  export let productPicture: string;
  let formSubmitted = false;

  export let product = {
    name: name,
    productLongDesc: productLongDesc,
    productCategory: productCategory,
    productShortDesc: productShortDesc,
    productID: productID,
    isSold: isSold,
    isVisible: isVisible,
    sellerID: sellerID,
    productPrice: productPrice,
    productPicture: productPicture,
  };

  async function add() {
    formSubmitted = true;
    try {
      await actorBackend.addToUserCart($fullName, product);
      toast("Added " + product.name + " to cart");
      $cart.value = $cart.value + 1;
      formSubmitted = false;
    } catch (error) {
      toast.error("There was an error adding the product. Please try again", {
        description: getFormattedDateTime(),
      });
      formSubmitted = false;
    }
  }

  function getFormattedDateTime() {
    const now = new Date();
    const dayOfWeek = now.toLocaleDateString("en-US", { weekday: "long" });
    const monthDay = now.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
    });
    const year = now.getFullYear();
    const time = now.toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });

    return `${dayOfWeek}, ${monthDay} ${year} at ${time}`;
  }
</script>

<div
  class="p-2 max-w-xs lg:max-w-md mx-auto border-[3.5px] border-zinc-400 bg-white shadow-md xl:shadow-lg rounded-lg overflow-hidden min-h-[650px] max-h-[650px] relative"
>
  <Carousel.Root>
    <Carousel.Content>
      <Carousel.Item
        ><img
          class="w-full h-96 object-cover"
          src={product.productPicture}
          alt={product.name}
        /></Carousel.Item
      >
    </Carousel.Content>
    <Carousel.Previous />
    <Carousel.Next />
  </Carousel.Root>
  <div class="p-4">
    <div class="flex justify-between mb-2">
      <h2 class="text-xl font-semibold">{@html product.name}</h2>
      <h2 class="text-xl font-semibold">
        {#each Object.keys(product.productPrice.currency) as currency}
          {#if product.productPrice.currency.hasOwnProperty(currency)}
            {product.productPrice.amount} {currency.toUpperCase()}
          {/if}
        {/each}
      </h2>
    </div>
    <p class="text-gray-600 mb-4">{@html product.productShortDesc}</p>
  </div>
  <div class="p-4 absolute bottom-0 w-full">
    <div class="flex justify-between gap-x-2">
      <Drawer.Root>
        <Drawer.Trigger
          class="border-2 border-zinc-200 p-1 w-3/5 h-full rounded-md hover:bg-zinc-300 hover:border-zinc-400"
          >More details</Drawer.Trigger
        >
        <Drawer.Content>
          <div class="mx-auto w-full max-w-sm h-full">
            <Drawer.Header>
              <Drawer.Title>{@html product.name}</Drawer.Title>
            </Drawer.Header>
            <div class="p-4 pb-0">
              <div class="flex items-center justify-center space-x-2">
                <div class="flex-1 text-center">
                  <div class="text-7xl font-bold tracking-tighter"></div>
                  <div
                    class="text-[0.7rem] text-start uppercase text-muted-foreground my-2"
                  >
                    {#each Object.keys(product.productPrice.currency) as currency}
                      {#if product.productPrice.currency.hasOwnProperty(currency)}
                        Price: {product.productPrice.amount}
                        {currency.toUpperCase()}
                      {/if}
                    {/each}
                  </div>
                  <div
                    class="text-[0.7rem] text-start uppercase text-muted-foreground my-2"
                  >
                    ProductID: {@html product.productID}
                  </div>
                  <div
                    class="text-[0.7rem] text-start uppercase text-muted-foreground my-2"
                  >
                    Category: {@html product.productCategory}
                  </div>
                  <div
                    class="text-[0.7rem] text-start uppercase text-muted-foreground my-2"
                  >
                    Seller: {@html product.sellerID}
                  </div>
                  <div
                    class="text-[0.7rem] text-start uppercase text-muted-foreground my-2"
                  >
                    Description: {@html product.productLongDesc}
                  </div>
                </div>
              </div>
              {#if product.sellerID !== $fullName}
                <Drawer.Footer>
                  {#if !formSubmitted}
                    <Button on:click={() => add()}>Add to cart</Button>
                  {:else}
                    <Button class="w-full" disabled>
                      <Reload class="flex justify-center h-4/5 animate-spin" />
                      Adding to Cart
                    </Button>
                  {/if}
                  <Drawer.Close asChild let:builder>
                    <Button builders={[builder]} variant="outline">Close</Button
                    >
                  </Drawer.Close>
                </Drawer.Footer>
              {:else}
                <Drawer.Footer>
                  <Button disabled>You already own this product</Button>
                  <Drawer.Close asChild let:builder>
                    <Button builders={[builder]} variant="outline">Close</Button
                    >
                  </Drawer.Close>
                </Drawer.Footer>
              {/if}
            </div>
          </div></Drawer.Content
        >
      </Drawer.Root>
      {#if product.sellerID !== $fullName}
        {#if !formSubmitted}
          <Button class="w-3/5" variant="default" on:click={() => add()}
            >Add to cart</Button
          >
        {:else}
          <Button class="w-3/5" disabled>
            <Reload class="w-full h-4/5 animate-spin" />
            Adding to Cart
          </Button>
        {/if}
      {:else}
        <Button class="w-3/5" variant="destructive" disabled
          >You're the owner</Button
        >
      {/if}
    </div>
  </div>
</div>
