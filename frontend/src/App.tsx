import "./App.css";
function App() {
	return (
		<div className="wrapper">
			<h1>CD Prozess eingeführt (Test)</h1>{" "}
			<h2>Testing mit vitest hinzugefügt</h2>
			<h3>Deployment Flow geändert von DockerHub zu ACR</h3>
			<h4>Staging Stand (Swap aus Stanging mit Production)</h4>
			<h4>Terraform Import from Azure Environment </h4>
			<h4>Alerts / Monitoring via Terraform in Azure gesetzt</h4>
			<h4>Automatic Deployment to production: Swap staging with production</h4>
			<h3>production version uses fixed image tag instead of latest</h3>
			<h3>another blue green try</h3>
			<h2>try to see if staging gets latest build without manuual swap</h2>
			<h2>try if staging gets the last build</h2>
			<h2>
				Update: wieder hinzugefügt damit production die updates kriegt:
				<br />
				<br />
				linux_fx_version = "DOCKER|$ registry/project-1-frontend:latest"
			</h2>
			<h2>staging soll auch den latest image bekommen beim deploy</h2>
		</div>
	);
}

export default App;
