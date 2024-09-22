<script lang="ts">
  import * as Table from "$lib/components/ui/table/index.js";
  import { actorBackend } from "$lib/motokoImports/backend";
  import { onMount } from "svelte";
  import Skeleton from "$lib/components/ui/skeleton/skeleton.svelte";
  import { fullName } from "$lib/data/stores/stores";
  import * as Sheet from "$lib/components/ui/sheet/index.js";
  import { Button } from "$lib/components/ui/button/index.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import { Label } from "$lib/components/ui/label/index.js";
  import { superForm, defaults } from "sveltekit-superforms/client";
  import { z } from "zod";
  import { zod } from "sveltekit-superforms/adapters";
  import * as Select from "$lib/components/ui/select";
  import { Textarea } from "$lib/components/ui/textarea/";
  import { toast } from "svelte-sonner";
  import Reload from "svelte-radix/Reload.svelte";

  let showSkeleton = true;
  let products: any[] = [];
  let loaded = false;
  let formSubmitted = false;
  let currentProduct: any = null;
  $: selectedCurrency = "KT";
  $: selectedCategory = "Electronics";

  const currencies = [{ value: "KT", label: "Knowledge Token" }];

  const categories = [
    { value: "Electronics", label: "Electronics" },
    { value: "Clothing", label: "Clothing & Apparel" },
    { value: "Home", label: "Home & Kitchen" },
    { value: "Beauty & Personal Care", label: "Beauty & Personal Care" },
    { value: "Books", label: "Books & Audible" },
    { value: "Toys & Games", label: "Toys & Games" },
    { value: "Sports & Outdoors", label: "Sports & Outdoors" },
    { value: "Automotive", label: "Automotive" },
    { value: "Office Products", label: "Office Products" },
    { value: "Musical Instruments", label: "Musical Instruments" },
  ];

  const editProductSchema = z.object({
    Name: z.string().min(2).max(15),
    sDesc: z.string().min(10).max(200),
    lDesc: z.string().min(50).max(2069),
    price: z.number().min(1).max(100000),
  });

  const { form, enhance, constraints } = superForm(
    defaults(zod(editProductSchema)),
    {
      SPA: true,
      validators: zod(editProductSchema),
      onSubmit() {
        formSubmitted = true;
      },
      onUpdated({ form }) {
        handleEditProduct(form.data);
      },
    },
  );

  onMount(async () => {
    try {
      products = await actorBackend.getAllProductTypes();
      showSkeleton = false;
      loaded = true;
    } catch (err: unknown) {
      console.error(err);
    }
  });

  async function handleEditProduct(formData) {
    if (!currentProduct) {
      console.error("No product selected for editing");
      return;
    }

    if (
      !formData.Name ||
      !selectedCategory ||
      !formData.price ||
      !formData.sDesc ||
      !formData.lDesc
    ) {
      toast.error("All fields are required", {
        description: getFormattedDateTime(),
      });
      formSubmitted = false;
      return;
    }

    try {
      const result = await actorBackend.editProduct(
        BigInt(currentProduct.productID),
        $fullName,
        formData.Name,
        selectedCategory,
        { currency: { kt: null }, amount: BigInt(formData.price) },
        formData.sDesc,
        formData.lDesc,
        true,
      );

      if ("ok" in result) {
        toast.success("Product updated successfully", {
          description: getFormattedDateTime(),
        });
        products = await actorBackend.getAllProductTypes();
      } else {
        toast.error("Failed to update product: " + result.err, {
          description: getFormattedDateTime(),
        });
      }
    } catch (error) {
      console.error("Error updating product:", error);
      toast.error(
        "An error occurred while updating the product: " + error.message,
        { description: getFormattedDateTime() },
      );
    } finally {
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

<h2 class="text-xl font-semibold ml-2 mb-5">Products</h2>
{#if showSkeleton}
  <div class="col-span-1"></div>
  <div class="col-span-10">
    <Table.Root>
      <Table.Caption>List of your products</Table.Caption>
      <Table.Header>
        <Table.Row class="max-[400px]:text-xs max-[500px]:text-md">
          <Table.Head class={innerWidth <= 800 ? "w-[33%]" : "w-1/5"}
            >Product Name</Table.Head
          >
          {#if innerWidth > 800}
            <Table.Head class={innerWidth <= 800 ? "w-[32%]" : "w-1-/10"}
              >Price</Table.Head
            >
            <Table.Head class={innerWidth <= 800 ? "w-[33%]" : "w-1-/10"}
              >Description</Table.Head
            >
          {/if}
          <Table.Head
            class="{innerWidth <= 800 ? 'w-[43%]' : 'w-1/5'} text-right"
            >More Details</Table.Head
          >
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {#each Array.from({ length: 20 }, (_, i) => i) as index}
          <Table.Row>
            <Table.Cell class="font-medium">
              <Skeleton class="w-[60%] h-[27px]" />
            </Table.Cell>
            {#if innerWidth > 800}
              <Table.Cell>
                <Skeleton class="w-[40%] h-[27px]" />
              </Table.Cell>
              <Table.Cell>
                <Skeleton class="w-[60%] h-[27px]" />
              </Table.Cell>
            {/if}
            <Table.Cell class="flex justify-end items-end">
              <Skeleton class="w-[40%] h-[27px]" />
            </Table.Cell>
          </Table.Row>
        {/each}
      </Table.Body>
    </Table.Root>
  </div>
  <div class="col-span-1"></div>
{:else}
  <div class="col-span-1"></div>
  <div class="col-span-12">
    {#if loaded}
      {#if products.length > 0}
        <Table.Root>
          <Table.Caption>List of your products</Table.Caption>
          <Table.Header>
            <Table.Row class="max-[400px]:text-xs max-[500px]:text-md">
              <Table.Head class={innerWidth <= 800 ? "w-[33%]" : "w-1/5"}
                >Product Name</Table.Head
              >
              {#if innerWidth > 800}
                <Table.Head class={innerWidth <= 800 ? "w-[32%]" : "w-1-/10"}
                  >Price</Table.Head
                >
                <Table.Head class={innerWidth <= 800 ? "w-[33%]" : "w-1-/10"}
                  >Description</Table.Head
                >
              {/if}
              <Table.Head
                class="{innerWidth <= 800 ? 'w-[43%]' : 'w-1/5'} text-right"
                >More Details</Table.Head
              >
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#each products as product}
              {#if product.sellerID === $fullName}
                <Table.Row>
                  <Table.Cell class="font-medium">
                    {product.name}
                  </Table.Cell>
                  {#if innerWidth > 800}
                    <Table.Cell>
                      {product.productPrice.amount}
                    </Table.Cell>
                    <Table.Cell>
                      {product.productShortDesc}
                    </Table.Cell>
                  {/if}
                  <Table.Cell class="flex justify-end items-end">
                    <Sheet.Root>
                      <Sheet.Trigger asChild let:builder>
                        <Button
                          builders={[builder]}
                          variant="outline"
                          on:click={() => {
                            currentProduct = product;
                            $form.Name = product.name;
                            $form.price = product.productPrice.amount;
                            $form.sDesc = product.productShortDesc;
                            $form.lDesc = product.productLongDesc;
                            selectedCategory = product.productCategory;
                            selectedCurrency = Object.keys(
                              product.productPrice.currency,
                            )[0].toUpperCase();
                          }}>View More Details</Button
                        >
                      </Sheet.Trigger>
                      <Sheet.Content side="right" class="w-auto xl:w-[400px]">
                        <Sheet.Header>
                          <Sheet.Title>Edit Product</Sheet.Title>
                          <Sheet.Description>
                            Make changes to your products here. Click save when
                            you're done.
                          </Sheet.Description>
                        </Sheet.Header>
                        <form method="POST" use:enhance class="space-y-6">
                          <div class="space-y-4">
                            <div class="space-y-2">
                              <Label for="Name">Name</Label>
                              <Input
                                type="text"
                                id="Name"
                                name="Name"
                                bind:value={$form.Name}
                                {...$constraints.Name}
                                class="w-full"
                              />
                            </div>
                            <div class="space-y-2">
                              <Label for="category">Category</Label>
                              <Select.Root
                                onSelectedChange={(v) => {
                                  v && (selectedCategory = v.value);
                                }}
                              >
                                <Select.Trigger class="w-full">
                                  <Select.Value
                                    placeholder={selectedCategory}
                                  />
                                </Select.Trigger>
                                <Select.Content>
                                  <Select.Group>
                                    <Select.Label>Category</Select.Label>
                                    {#each categories as category}
                                      <Select.Item
                                        value={category.value}
                                        label={category.label}
                                        >{category.label}</Select.Item
                                      >
                                    {/each}
                                  </Select.Group>
                                </Select.Content>
                              </Select.Root>
                            </div>
                            <div class="space-y-2">
                              <Label for="price">Price (KT)</Label>
                              <Input
                                type="number"
                                id="price"
                                bind:value={$form.price}
                                {...$constraints.price}
                                class="w-full"
                              />
                            </div>
                            <div class="space-y-2">
                              <Label for="sDesc">Short Description</Label>
                              <Input
                                type="text"
                                id="sDesc"
                                name="sDesc"
                                bind:value={$form.sDesc}
                                {...$constraints.sDesc}
                                class="w-full"
                              />
                            </div>
                            <div class="space-y-2">
                              <Label for="lDesc">Full Description</Label>
                              <Textarea
                                id="lDesc"
                                name="lDesc"
                                bind:value={$form.lDesc}
                                {...$constraints.lDesc}
                                class="w-full"
                              />
                            </div>
                          </div>
                          <Sheet.Footer>
                            {#if !formSubmitted}
                              <Button type="submit" class="w-full"
                                >Save changes</Button
                              >
                            {:else}
                              <Button disabled class="w-full">
                                <Reload class="mr-2 h-4 w-4 animate-spin" />
                                Updating Product
                              </Button>
                            {/if}
                          </Sheet.Footer>
                        </form>
                      </Sheet.Content>
                    </Sheet.Root>
                  </Table.Cell>
                </Table.Row>
              {/if}
            {/each}
          </Table.Body>
        </Table.Root>
      {/if}
    {/if}
  </div>
  <div class="col-span-1"></div>
{/if}
