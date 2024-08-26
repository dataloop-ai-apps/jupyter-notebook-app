<template>
    <DlThemeProvider :is-dark="isDark">
        <div v-if="!isReady" class="loading-spinner">
            <DlSpinner text="Loading App..." size="128px" />
        </div>
        <div v-if="showNotebook">
            <div class="container">
                <iframe
                    id="iframe1"
                    ref="contentIframe"
                    class="frame-container"
                    frameBorder="0"
                    sandbox="allow-scripts allow-same-origin"
                ></iframe>
            </div>
        </div>
    </DlThemeProvider>
</template>

<script setup lang="ts">
import { DlThemeProvider, DlSpinner } from '@dataloop-ai/components'
import { DlEvent, DlFrameEvent, ThemeType } from '@dataloop-ai/jssdk'
import { ref, onMounted, computed, nextTick } from 'vue-demi'

const contentIframe = ref<HTMLIFrameElement | null>(null)
const isReady = ref<boolean>(false)
const currentTheme = ref<ThemeType>(ThemeType.LIGHT)
const operationRunning = ref<boolean>(true)
const datasetId = ref<string>(null)
const projectId = ref<string>(null)
const datasetName = ref<string>(null)
const projectName = ref<string>(null)
const showNotebook = computed<boolean>(() => {
    // notebookPath.value is not null
    return !!notebookPath.value
})
const frameLoadFailed = ref<boolean>(false)
const route = ref<string>('datasetBrowser')
const notebookPath = ref<string>('app/notebooks/upload_and_manage_items.ipynb')
const isDark = computed<boolean>(() => {
    return currentTheme.value === ThemeType.DARK
})

const postContext = async (url, data) => {
    try {
        const response = await fetch(url, {
            method: 'POST', // or 'PUT'
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })

        if (!response.ok) {
            throw new Error('Network response was not ok')
        }

        const responseData = await response.json()
        // Handle your response data here
    } catch (error) {
        console.error('There was a problem with your fetch operation:', error)
        // Handle errors here
    }
}

const updateNotebook = async () => {
    try {
        await postContext('/api/update-context', {
            dataset_id: datasetId.value || 'dataset_id',
            project_id: projectId.value || 'project_id',
            project_name: projectName.value || 'project_name',
            dataset_name: datasetName.value || 'dataset_name',
            notebook_path: notebookPath.value || 'notebook_path'
        })
    } catch (e) {
        console.error('Failed updating notebook', e)
    }
}

const loadiFrameWithContext = async () => {
    try {
        await updateNotebook()
        if (notebookPath.value === null) {
            return
        }
        contentIframe.value.onload = () => {
            // Once the iframe is loaded, set isReady to true
            isReady.value = true
        }
        contentIframe.value.src = `/jupyter/notebooks/${notebookPath.value}?kernel_name=python3`
    } catch (e) {
        console.error('Failed loading frame', e)
        operationRunning.value = false
        frameLoadFailed.value = true
    }
}

const getContext = async () => {
    try {
        const project = await window.dl.projects.get()
        const dataset = await window.dl.datasets.get()
        // const project = { id: '123', name: 'project' }
        // const dataset = { id: '456', name: 'dataset' }

        projectId.value = project?.id ?? null
        projectName.value = project?.name ?? null
        datasetId.value = dataset?.id ?? null
        datasetName.value = dataset?.name ?? null
    } catch (e) {
        console.error('Failed getting context', e)
    }
}
const prepareAndLoadFrame = async () => {
    try {
        if (route.value === 'datasetBrowser') {
            notebookPath.value = 'app/notebooks/upload_and_manage_items.ipynb'
        } 
        else if (
            route.value === 'project' ||
            route.value === 'dataManagement'
        ) {
            notebookPath.value = 'app/notebooks/manage_datasets.ipynb'
        }
        else if (route.value == 'modelManagement') {
            notebookPath.value = 'app/notebooks/model_management.ipynb'
        }
        else {
            notebookPath.value = null
        }
        nextTick(() => {
            getContext().then(() => {
                nextTick(async () => {
                    await loadiFrameWithContext()
                })
            })
        })
    } catch (e) {
        console.error('Failed preparing frame', e)
    }
}

const saveNotebook = async () => {
    const saveButton = contentIframe.value.contentWindow.document
        .getElementById('save-notbook')
        .getElementsByClassName('btn')

    if (saveButton && saveButton.length > 0) {
        ;(saveButton[0] as HTMLElement).click()
    }
}
onMounted(() => {
    window.dl.on(DlEvent.READY, async () => {
        const settings = await window.dl.settings.get()
        // @ts-ignore
        route.value = settings.currentRoute
        currentTheme.value = settings.theme
        window.dl.on(DlEvent.THEME, (data) => {
            currentTheme.value = data
        })
        window.dl.on('navigation', async (data) => {
            if (
                data.from.name == data.to.name &&
                data.from.params.projectId == data.to.params.projectId
            ) {
                return
            }
            isReady.value = false
            route.value = data.to.name
            await saveNotebook()
            // wait for the notebook to save
            await new Promise((resolve) => {
                setTimeout(async () => {
                    await prepareAndLoadFrame()
                }, 1000)
            })
        })
        await prepareAndLoadFrame()
    })
})
</script>

<style scoped>
#iframe1 {
    width: 100vw;
    height: 100vh;
}

.container {
    width: 100vw;
    height: 100vh;
    justify-content: center;
    margin: 0%;
}

.container iframe {
    width: 100vh;
    height: 100vh;
}

.loading-spinner {
    display: grid;
    place-items: center;
    height: 100vh;
}

.top-bar {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid var(--dl-color-disabled);
}
</style>
